use_bpm 72

# ===== Helpers =====
define :sec do |s| s.to_f * (current_bpm/60.0) end

define :fade_to do |fx, to_amp, secs=8, steps=12, key=:amp_mem|
  from=get(key)||0.0; d=(to_amp-from)/steps.to_f
  steps.times do |i|
    a=from+d*(i+1); control fx, amp:a; set key,a
    sleep sec(secs/steps.to_f)
  end
end

define :loop_xfade do |path, amp:0.1, st:0.01, fn:0.99, xf:0.25, pan:0|
  base=sample_duration(path); eff=base*(fn-st)
  sample path, amp:amp, start:st, finish:fn, attack:xf, sustain:eff-2*xf, release:xf, pan:pan
  sleep eff-xf
end

# コントロール用フラグ
set :air_plane_running, true

# ===== Airplane loop =====
live_loop :air_plane do
  if get(:air_plane_running)
    sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/airplane-talk-piano.mp3", amp: 0.01
    sleep 2
  else
    stop
  end
end

# ===== Kamide-ririku (10秒後に一回のみ) =====
in_thread do
  sleep 10
  if get(:air_plane_running)  # まだairplaneが動いている間に再生
    sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/kamide-ririku.mp3", amp: 0.1
    # ririku再生後にzakuzaku開始のcueを送る
    sleep sample_duration("/Users/shinta/git/github.com/gx14ac/mpc/assets/kamide-ririku.mp3")
    cue :ririku_done
  end
end

# ===== Delay start (20s airplane only) =====
in_thread do
  sleep 20
  set :air_plane_running, false   # 飛行機ループを停止
  cue :airplane_done
end

# ===== Zakuzaku mp3 (random gate) =====
zak="/Users/shinta/git/github.com/gx14ac/mpc/assets/walk-zakuzaku.mp3"
z_wait=0           # ← すぐ運用開始
z_fade=8
z_lvl=0.9          # ← ゲート最大音量を少し下げる
z_idle=[4,16]       # ← 出現間隔を短く
z_prob=1.0         # ← 毎回出る
z_loops=[4,16]      # ← 出現時に2〜4ループ滞在
z_xf=0.25

with_fx :level, amp:0 do |fx_z|
  sync :ririku_done
  
  live_loop :z_player do
    with_fx :hpf, cutoff: 20 do
      with_fx :lpf, cutoff: 90 do
        with_fx :reverb, room: 0.3, mix: 0.15 do
          # PANを左右にランダムに振って気持ちいい感じに
          pan_pos = rrand(-0.6, 0.6)
          loop_xfade zak, amp: 0.09, st: 0.01, fn: 0.99, xf: z_xf, pan: pan_pos
        end
      end
    end
  end
  
  # ゲート制御（頻度多め＆大きめ）
  live_loop :z_gate do
    if tick==0
      control fx_z, amp: 0
      sleep sec(z_wait)
    end
    
    control fx_z, amp: 0
    sleep sec(rrand_i(z_idle.first, z_idle.last))
    
    if rand < z_prob
      fade_to fx_z, z_lvl, z_fade, 12, :z_amp
      eff = sample_duration(zak) * 0.98
      n   = rrand_i(z_loops.first, z_loops.last)
      sleep n * (eff - z_xf)
      fade_to fx_z, 0.0, z_fade, 12, :z_amp
    end
  end
end

# ===== Bells (softened) =====
# ===== Paths / Params =====
bell_main = "/Users/shinta/git/github.com/gx14ac/mpc/assets/ring-roba.mp3"
bell_light= "/Users/shinta/git/github.com/gx14ac/mpc/assets/roba-light-ring.mp3"
karankoron= "/Users/shinta/git/github.com/gx14ac/mpc/assets/karankoron.mp3"
bars_to_full=32; slice_len=0.10
main_amp_rng=[0.4,0.8]; light_amp_rng=[0.3,0.7]
lpf_rng=(97..120); hpf_cut=60   # ほんの少し暗め
# ===== Bells main =====
live_loop :bells do
  prog = get(:bell_prog) || 0.0    # 0.0→1.0
  
  # 密度：成長に合わせて少しだけ増える（控えめ）
  mh = [[1 + (prog * 3).round, 4].min, 1].max  # main 1→4/8
  lh = [[1 + (prog * 2).round, 3].min, 1].max  # light1→3/8
  kh = [[1 + (prog * 1).round, 2].min, 1].max  # karankoron 1→2/8
  
  rot = (vt / 4.0).floor % 8
  pm  = spread(mh, 8).rotate(rot)
  pl  = spread(lh, 8).rotate((rot + 2) % 8)
  pk  = spread(kh, 8).rotate((rot + 4) % 8)
  
  # 全体を控えめに：成長しても出過ぎないレンジ
  m_amp = 0.28 + 0.22 * prog
  l_amp = 0.22 + 0.18 * prog
  k_amp = 0.20 + 0.15 * prog  # karankoron音量
  
  with_fx :hpf, cutoff: hpf_cut do
    # 高域を少し落として丸める（固定気味で安定）
    with_fx :rlpf, cutoff: rrand(94, 102), res: 0.55 do
      with_fx :reverb, room: 0.35, mix: 0.16, damp: 0.7 do
        with_fx :echo, phase: 0.5, decay: 3.5, mix: 0.10 do
          8.times do |i|
            acc = (i % 4 == 0) ? 0.90 : 0.86   # 軽いアクセントのみ
            
            # main（短く・やわらかく・中央寄り）
            if pm[i]
              st = rrand(0.025, 0.045); fn = [st + slice_len * 0.65, 0.995].min
              sample bell_main,
                start: st, finish: fn,
                amp: m_amp * acc * 0.9,
                attack: 0.014, release: 0.10,
                pan: rrand(-0.08, 0.08)
            end
            
            # light（さらに控えめ・少し左寄り・暗め）
            if pl[i]
              st = rrand(0.020, 0.040); fn = [st + slice_len * 0.60, 0.995].min
              with_fx :rlpf, cutoff: rrand(90, 98), res: 0.5 do
                sample bell_light,
                  start: st, finish: fn,
                  amp: l_amp * acc * 0.85,
                  attack: 0.016, release: 0.10,
                  pan: rrand(-0.10, 0.02)
              end
            end
            
            # karankoron（控えめ・右寄り・クリア）
            if pk[i]
              st = rrand(0.015, 0.035); fn = [st + slice_len * 0.70, 0.995].min
              sample karankoron,
                start: st, finish: fn,
                amp: k_amp * acc * 0.80,
                attack: 0.012, release: 0.08,
                pan: rrand(0.05, 0.15)
            end
            
            sleep 0.5
          end
        end
      end
    end
  end
end

# ===== Roma Master Voice (ビート前に一回のみ) =====
in_thread do
  sleep sec(75)  # ビートの5秒前に再生
  sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/roma-master-voice.mp3", amp: 0.05
end

# ===== Beat (gate in) =====
beat_wait=80; beat_fade=10; beat_lvl=0.8
with_fx :level, amp:0 do |fx_b|
  in_thread do
    sleep sec(beat_wait); fade_to fx_b, beat_lvl, beat_fade, 12, :beat_amp
  end
  # ---- キック（4つ打ち）----
  live_loop :kick do
    sample :bd_ada, amp: 0.7, cutoff: 90
    sleep 2
  end
  
  # ---- ハイハット（オフビート）----
  live_loop :hats do
    sleep 0.5
    sample :drum_cymbal_soft, amp: 0.25, sustain: 0.01, release: 0.08, cutoff: 115
    sleep 0.5
  end
  
  ##| ---- オープンハット（4小節ごと）----
  live_loop :ohat do
    with_fx :lpf, cutoff: 120 do
      3.times { sleep 4 }
      sample :drum_cymbal_open, amp: 0.20, sustain: 0.08, release: 0.2
      sleep 4
    end
  end
end

# ===== Piano (gate in) =====
piano_wait=100; piano_fade=10; piano_lvl=0.8
with_fx :level, amp:0 do |fx_p|
  in_thread do
    sleep sec(piano_wait); fade_to fx_p, piano_lvl, piano_fade, 12, :piano_amp
  end
  live_loop :piano do
    use_synth :piano
    play_chord [:a3,:c4,:e4,:g4], amp:0.35; sleep 2
    play_chord [:d3,:f3,:a3,:c4], amp:0.35; sleep 2
    play_chord [:g3,:b3,:d4,:f4], amp:0.35; sleep 2
    play_chord [:c3,:e3,:g3,:b3], amp:0.35; sleep 2
  end
end

# ===== Indian Temple Synth (幻想的な寺院の音) =====
temple_wait=90; temple_fade=15; temple_lvl=0.6
with_fx :level, amp:0 do |fx_temple|
  in_thread do
    sleep sec(temple_wait); fade_to fx_temple, temple_lvl, temple_fade, 16, :temple_amp
  end
  
  # メインドローン（低音の持続音）
  live_loop :temple_drone do
    with_fx :reverb, room: 0.9, mix: 0.7, damp: 0.3 do
      with_fx :echo, phase: 1.5, decay: 8, mix: 0.4 do
        with_fx :lpf, cutoff: 70, res: 0.3 do
          use_synth :hollow
          play :c2, amp: 0.4, attack: 8, sustain: 16, release: 8, cutoff: 60
          sleep 32
        end
      end
    end
  end
  
  # メロディックドローン（インド風スケール）
  live_loop :temple_melody do
    # インドのラーガ風スケール（ミクソリディアン＋フラット2度）
    notes = [:c3, :db3, :e3, :f3, :g3, :ab3, :bb3, :c4]
    
    with_fx :reverb, room: 0.8, mix: 0.6, damp: 0.4 do
      with_fx :echo, phase: 2.0, decay: 6, mix: 0.3 do
        with_fx :wobble, phase: 0.8, cutoff_min: 60, cutoff_max: 120, mix: 0.3 do
          with_fx :lpf, cutoff: rrand(80, 95), res: 0.4 do
            use_synth :prophet
            
            # ゆったりとしたメロディー
            4.times do
              note = notes.choose
              play note, amp: rrand(0.15, 0.25), 
                   attack: rrand(3, 6), sustain: rrand(8, 12), release: rrand(4, 8),
                   cutoff: rrand(70, 85), res: 0.3,
                   pan: rrand(-0.3, 0.3)
              sleep rrand(8, 16)
            end
          end
        end
      end
    end
  end
  
  # 高音のきらめき（遠くの鐘のような）
  live_loop :temple_shimmer do
    with_fx :reverb, room: 0.9, mix: 0.8, damp: 0.2 do
      with_fx :echo, phase: 3.0, decay: 10, mix: 0.5 do
        with_fx :hpf, cutoff: 90 do
          use_synth :sine
          
          if one_in(3)  # 時々だけ鳴らす
            harmonics = [:c5, :e5, :g5, :c6]
            note = harmonics.choose
            play note, amp: rrand(0.08, 0.15),
                 attack: rrand(2, 4), sustain: rrand(4, 8), release: rrand(6, 12),
                 pan: rrand(-0.5, 0.5)
          end
          
          sleep rrand(12, 24)
        end
      end
    end
  end
end
