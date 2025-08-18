#### MPC MAIN ####
use_bpm 72

# ===== Helpers =====
define :sec do |s| s.to_f * (current_bpm/60.0) end
define :fade_to do |fx, to_amp, secs=8, steps=12, key=:amp_mem|
  from=get(key)||0.0; d=(to_amp-from)/steps.to_f
  steps.times{|i| a=from+d*(i+1); control fx, amp:a; set key,a; sleep sec(secs/steps.to_f)}
end
define :loop_xfade do |path, amp:0.1, st:0.01, fn:0.99, xf:0.25, pan:0|
  base=sample_duration(path); eff=base*(fn-st)
  sample path, amp:amp, start:st, finish:fn, attack:xf, sustain:eff-2*xf, release:xf, pan:pan
  sleep eff-xf
end

set :air_plane_running, true

# ===== Timeline Events =====
in_thread do
  live_loop :air_plane do
    if get(:air_plane_running)
      sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/airplane-talk-piano.mp3", amp: 0.01
      sleep 2
    else
      stop
    end
  end
end

in_thread do
  sleep 10
  sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/kamide-ririku.mp3", amp: 0.06
  sleep sample_duration("/Users/shinta/git/github.com/gx14ac/mpc/assets/kamide-ririku.mp3")
  cue :ririku_done
end

in_thread do
  sleep 20
  set :air_plane_running, false
  cue :airplane_done
end

in_thread do
  sleep 75
  sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/roma-master-voice.mp3", amp: 0.08
end

# ===== Zakuzaku =====
zak="/Users/shinta/git/github.com/gx14ac/mpc/assets/walk-zakuzaku.mp3"
with_fx :level, amp:0 do |fx_z|
  sync :ririku_done
  
  live_loop :z_player do
    with_fx :hpf, cutoff: 20 do
      with_fx :lpf, cutoff: 90 do
        with_fx :reverb, room: 0.3, mix: 0.15 do
          loop_xfade zak, amp: 0.18, st: 0.01, fn: 0.99, xf: 0.25, pan: rrand(-0.6, 0.6)
        end
      end
    end
  end
  
  live_loop :z_gate do
    if tick == 0
      control fx_z, amp: 0
      sleep sec(10)
    end
    control fx_z, amp: 0
    sleep sec(rrand_i(4, 16))
    if rand < 1.0
      fade_to fx_z, 0.9, 8, 12, :z_amp
      n = rrand_i(4, 16)
      sleep n * (sample_duration(zak) * 0.98 - 0.25)
      fade_to fx_z, 0.0, 8, 12, :z_amp
    end
  end
end

live_loop :roma_voice do
  sleep rrand(85, 90)
  # 100%の確率で再生
  if one_in(1)
    sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/roma-master-voice.mp3",
      amp: rrand(0.04, 0.09),  # 音量もランダム
      pan: rrand(-0.2, 0.2)    # パンもランダム
  end
end

# ===== Bells =====
bell_main = "/Users/shinta/git/github.com/gx14ac/mpc/assets/ring-roba.mp3"
bell_light = "/Users/shinta/git/github.com/gx14ac/mpc/assets/roba-light-ring.mp3"
karankoron = "/Users/shinta/git/github.com/gx14ac/mpc/assets/karankoron.mp3"

live_loop :bells do
  prog = get(:bell_prog) || 0.0
  mh = [[1 + (prog * 3).round, 4].min, 1].max
  lh = [[1 + (prog * 2).round, 3].min, 1].max
  kh = [[1 + (prog * 1).round, 2].min, 1].max
  
  rot = (vt / 4.0).floor % 8
  pm = spread(mh, 8).rotate(rot)
  pl = spread(lh, 8).rotate((rot + 2) % 8)
  pk = spread(kh, 8).rotate((rot + 4) % 8)
  
  m_amp = 0.28 + 0.22 * prog
  l_amp = 0.22 + 0.18 * prog
  k_amp = 0.20 + 0.15 * prog
  
  with_fx :hpf, cutoff: 60 do
    with_fx :rlpf, cutoff: rrand(94, 102), res: 0.55 do
      with_fx :reverb, room: 0.35, mix: 0.16, damp: 0.7 do
        with_fx :echo, phase: 0.5, decay: 3.5, mix: 0.10 do
          8.times do |i|
            acc = (i % 4 == 0) ? 0.90 : 0.86
            
            if pm[i]
              st = rrand(0.025, 0.045)
              fn = [st + 0.10 * 0.65, 0.995].min
              sample bell_main, start: st, finish: fn, amp: m_amp * acc * 0.9,
                attack: 0.014, release: 0.10, pan: rrand(-0.08, 0.08)
            end
            
            if pl[i]
              st = rrand(0.020, 0.040)
              fn = [st + 0.10 * 0.60, 0.995].min
              with_fx :rlpf, cutoff: rrand(90, 98), res: 0.5 do
                sample bell_light, start: st, finish: fn, amp: l_amp * acc * 0.85,
                  attack: 0.016, release: 0.10, pan: rrand(-0.10, 0.02)
              end
            end
            
            if pk[i]
              st = rrand(0.015, 0.035)
              fn = [st + 0.10 * 0.70, 0.995].min
              sample karankoron, start: st, finish: fn, amp: k_amp * acc * 0.80,
                attack: 0.012, release: 0.08, pan: rrand(0.05, 0.15)
            end
            
            sleep 0.5
          end
        end
      end
    end
  end
end

# ===== Beat =====
beat_wait = 80
with_fx :level, amp: 0 do |fx_b|
  in_thread do
    sleep sec(beat_wait)
    fade_to fx_b, 0.8, 10, 12, :beat_amp
  end
  
  live_loop :kick do
    sample :bd_ada, amp: 0.5, cutoff: 90
    sleep 2
  end
  
  live_loop :hats do
    sleep 0.5
    sample :drum_cymbal_soft, amp: 0.25, sustain: 0.01, release: 0.08, cutoff: 115
    sleep 0.5
  end
  
  live_loop :ohat do
    with_fx :lpf, cutoff: 120 do
      3.times { sleep 4 }
      sample :drum_cymbal_open, amp: 0.20, sustain: 0.08, release: 0.2
      sleep 4
    end
  end
end

# ===== Piano V3 (120秒後にフェードイン) =====
piano_wait=120; piano_fade=15; piano_lvl=0.8
with_fx :level, amp:0 do |fx_piano|
  in_thread do
    sleep piano_wait; fade_to fx_piano, piano_lvl, piano_fade, 16, :piano_amp
  end
  
  live_loop :piano_v3 do
    with_fx :reverb, room: 0.8, mix: 0.6 do
      with_fx :lpf, cutoff: 85 do
        with_fx :echo, phase: 1.5, decay: 4, mix: 0.3 do
          use_synth :piano
          x = 72
          z = 0.3
          i = get(:piano_counter) || 0
          
          # ミニマルな反復パターン
          pattern = [0, 4, 7, 4, 0, -3, 0, 2]
          delays = [3, 1, 2, 1, 2, 1.5, 1, 2.5]
          
          pattern.zip(delays).each_with_index do |(note, delay), idx|
            amp_variation = z + rrand(-0.05, 0.1)
            pan_pos = 0.7 + rrand(-0.2, 0.2)
            attack_time = rrand(0.1, 0.3)
            
            play x + note,
              pan: pan_pos,
              amp: amp_variation,
              attack: attack_time,
              release: delay * 0.8
            sleep delay
          end
          
          # 時々高音域の装飾
          if one_in(3)
            play x + 19, pan: 0.9, amp: z * 0.7, attack: 0.5, release: 4
            sleep 2
          end
          
          if i == 3
            # アンビエント風エンディング
            play x + 12, pan: 0.8, amp: z + 0.2, attack: 2, release: 12
            sleep 4
            play x + 7, pan: 0.9, amp: z + 0.15, attack: 3, release: 10
            sleep 10
            set :piano_counter, 0
          else
            sleep 1
            set :piano_counter, i + 1
          end
        end
      end
    end
  end
end


# ===== Ambient Bass Hybrid (130秒後フェードイン) =====
bass_wait=130; bass_fade=16; bass_lvl=0.08
with_fx :level, amp:0 do |fx_bass|
  in_thread do
    sleep bass_wait; fade_to fx_bass, bass_lvl, bass_fade, 18, :bass_amp
  end
  
  # メインベース
  live_loop :ambient_bass do
    with_fx :reverb, room: 0.6, mix: 0.3 do
      with_fx :lpf, cutoff: 45, res: 0.2 do
        with_fx :echo, phase: 3.0, decay: 5, mix: 0.15 do
          use_synth :hollow
          x = 48
          z = 0.35
          
          # ピアノパターンに呼応するベース
          bass_pattern = [0, 4, 7, 4, 0, -3, 0, 2]
          bass_delays = [6, 2, 4, 2, 4, 3, 2, 5]  # ピアノより長い音価
          
          bass_pattern.zip(bass_delays).each do |note, delay|
            play x + note,
              amp: z + rrand(-0.05, 0.08),
              attack: rrand(0.8, 1.5),
              sustain: delay * 0.4,
              release: delay * 0.6,
              cutoff: rrand(65, 85),
              pan: rrand(-0.05, 0.05)
            
            sleep delay
          end
        end
      end
    end
  end
  
  # サブベース（時々）
  live_loop :sub_accent do
    sleep rrand(32, 48)  # 不規則な間隔
    
    if one_in(2)  # 50%の確率
      with_fx :reverb, room: 0.8, mix: 0.2 do
        with_fx :lpf, cutoff: 45 do
          use_synth :subpulse
          play 36,
            amp: 0.4,
            attack: 3,
            sustain: 8,
            release: 12,
            cutoff: 40,
            pulse_width: 0.5
        end
      end
    end
  end
end
