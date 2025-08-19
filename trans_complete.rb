# ===== TRANS COMPLETE - 歩行からビートへ、そして幻想的な寺院へ =====
use_bpm 100
define :sec do |s|; s * (60.0 / current_bpm); end
define :fade_to do |fx, amp, fade_time|; (fade_time * 4).times { |i| control fx, amp: amp * (i + 1) / (fade_time * 4).to_f; sleep fade_time / (fade_time * 4) }; end

# ===== PART 1: 歩行の進化（0-20分） =====
live_loop :walking_evolution do
  time_elapsed = vt
  
  # 20分で歩行パートを終了
  if time_elapsed > sec(1200); stop; end
  
  if time_elapsed < sec(60)  # Phase 1: 自然な歩行
    base_interval = rrand(1.2, 2.8)
    base_interval *= rrand(1.5, 2.5) if one_in(8)  # 立ち止まり
    base_interval *= rrand(0.4, 0.7) if one_in(6)  # 急ぎ足
    sleep base_interval
    sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/walk-zakuzaku.mp3", amp: rrand(0.08, 0.15), rate: rrand(0.9, 1.1), pan: rrand(-0.1, 0.1), cutoff: rrand(75, 90), attack: rrand(0.02, 0.08), release: rrand(0.2, 0.5)
    
  elsif time_elapsed < sec(120)  # Phase 2: テンポ安定化
    stability = (time_elapsed - sec(60)) / sec(60)
    base_interval = 1.8 - (stability * 0.6)
    random_factor = (1 - stability) * 0.4
    sleep base_interval + rrand(-random_factor, random_factor)
    sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/walk-zakuzaku.mp3", amp: rrand(0.1, 0.18), rate: rrand(0.95, 1.05), pan: rrand(-0.2, 0.2), cutoff: rrand(80, 95), attack: 0.03, release: 0.4
    
  elsif time_elapsed < sec(240)  # Phase 3: ビート準備（アクセント追加）
    sync_progress = (time_elapsed - sec(120)) / sec(120)
    current_interval = 1.2 - (sync_progress * 0.6)
    tempo_wobble = (1 - sync_progress) * 0.15
    sleep current_interval + rrand(-tempo_wobble, tempo_wobble)
    
    base_amp = rrand(0.12, 0.22)
    accent_amp = one_in([[2, (10 - (sync_progress * 8)).to_i].max, 10].min) ? base_amp * (1.5 + sync_progress) : base_amp
    sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/walk-zakuzaku.mp3", amp: accent_amp, rate: rrand(0.98, 1.12), pan: rrand(-0.3, 0.3), cutoff: rrand(85, 105), attack: 0.02, release: 0.5
    
  elsif time_elapsed < sec(420)  # Phase 4: ビート共存（音量調整）
    beat_time = time_elapsed - sec(240)
    fade_factor = beat_time < sec(15) ? 1.0 - (beat_time / sec(15) * 0.65) : 0.35
    sleep 0.6
    sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/walk-zakuzaku.mp3", amp: rrand(0.08, 0.15) * fade_factor, rate: rrand(1.0, 1.15), pan: rrand(-0.4, 0.4), cutoff: rrand(80, 100), attack: 0.03, release: 1.0
    
  elsif time_elapsed < sec(1200)  # Phase 5: 寺院への移行準備（18-20分で徐々にフェード）
    transition_time = time_elapsed - sec(1080)  # 18分から開始
    fade_factor = transition_time < sec(120) ? 1.0 - (transition_time / sec(120) * 0.8) : 0.2
    interval_factor = 1.0 + (transition_time / sec(120) * 3)
    sleep 0.6 * interval_factor
    sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/walk-zakuzaku.mp3", amp: rrand(0.01, 0.05) * fade_factor, rate: rrand(0.6, 0.8), pan: rrand(-0.8, 0.8), cutoff: rrand(50, 70), attack: rrand(0.2, 0.5), release: rrand(2.0, 4.0)
  end
end

# ===== ビートセクション（7分かけて段階的構築、18分でフェードアウト開始） =====
# キック（音量控えめ）
with_fx :level, amp: 0 do |fx_kick|; in_thread do; sleep sec(300); fade_to fx_kick, 0.6, 90; end
  live_loop :kick do; sleep sec(300)
    loop do; time_elapsed = vt; beat_time = time_elapsed - sec(300)
      if time_elapsed > sec(1080)  # 18分後からフェードアウト
        fadeout_time = time_elapsed - sec(1080)
        fade_factor = fadeout_time < sec(120) ? 1.0 - (fadeout_time / sec(120)) : 0
        if fade_factor > 0
          sample :bd_ada, amp: 0.19 * fade_factor, cutoff: 82; sleep 2.4
        else; stop; end
      else
        if beat_time < sec(45); sample :bd_ada, amp: 0.12, cutoff: 78; sleep 4.8
        elsif beat_time < sec(90); sample :bd_ada, amp: 0.14, cutoff: 80; sleep 3.6
        elsif beat_time < sec(120); sample :bd_ada, amp: 0.17, cutoff: 82; sleep 2.4
        else; sample :bd_ada, amp: 0.19, cutoff: 82; sleep 2.4; end
      end
    end
  end; end

# ハイハット
with_fx :level, amp: 0 do |fx_hats|; in_thread do; sleep sec(330); fade_to fx_hats, 0.7, 60; end
  live_loop :hats do; sleep sec(330)
    loop do; time_elapsed = vt; hat_time = time_elapsed - sec(330)
      if time_elapsed > sec(1080)  # 18分後からフェードアウト
        fadeout_time = time_elapsed - sec(1080)
        fade_factor = fadeout_time < sec(120) ? 1.0 - (fadeout_time / sec(120)) : 0
        if fade_factor > 0
          sleep 0.6; sample :drum_cymbal_soft, amp: 0.25 * fade_factor, sustain: 0.01, release: 0.08, cutoff: 112; sleep 0.6
        else; stop; end
      else
        if hat_time < sec(30); sample :drum_cymbal_soft, amp: 0.12, sustain: 0.01, release: 0.08, cutoff: 108; sleep 2.4
        elsif hat_time < sec(60); sample :drum_cymbal_soft, amp: 0.16, sustain: 0.01, release: 0.08, cutoff: 110; sleep 1.2
        else; sleep 0.6; sample :drum_cymbal_soft, amp: 0.25, sustain: 0.01, release: 0.08, cutoff: 112; sleep 0.6; end
      end
    end
  end; end

# オープンハット（音量控えめ）
with_fx :level, amp: 0 do |fx_ohat|; in_thread do; sleep sec(360); fade_to fx_ohat, 0.5, 45; end
  live_loop :ohat do; sleep sec(360)
    loop do; time_elapsed = vt
      if time_elapsed > sec(1080)  # 18分後からフェードアウト
        fadeout_time = time_elapsed - sec(1080)
        fade_factor = fadeout_time < sec(120) ? 1.0 - (fadeout_time / sec(120)) : 0
        if fade_factor > 0
          with_fx :lpf, cutoff: 115 do; 3.times { sleep 4.8 }; sample :drum_cymbal_open, amp: 0.15 * fade_factor, sustain: 0.06, release: 0.15; sleep 4.8; end
        else; stop; end
      else
        with_fx :lpf, cutoff: 115 do; 3.times { sleep 4.8 }; sample :drum_cymbal_open, amp: 0.15, sustain: 0.06, release: 0.15; sleep 4.8; end
      end
    end
  end; end

# ===== 遠くのベル（キック登場と同時、18分でフェードアウト） =====
bell_main = "/Users/shinta/git/github.com/gx14ac/mpc/assets/ring-roba.mp3"
bell_light = "/Users/shinta/git/github.com/gx14ac/mpc/assets/roba-light-ring.mp3"
karankoron = "/Users/shinta/git/github.com/gx14ac/mpc/assets/karankoron.mp3"

with_fx :level, amp: 0 do |fx_bells|; in_thread do; sleep sec(300); fade_to fx_bells, 0.4, 120; end
  live_loop :distant_bells do; sleep sec(300)
    loop do; time_elapsed = vt; bell_time = time_elapsed - sec(300)
      
      if time_elapsed > sec(1080)  # 18分後からフェードアウト
        fadeout_time = time_elapsed - sec(1080)
        fade_factor = fadeout_time < sec(120) ? 1.0 - (fadeout_time / sec(120)) : 0
        distant_amp = (0.12 + (bell_time / sec(120) * 0.08)) * fade_factor
      else
        distant_amp = 0.12 + (bell_time / sec(120) * 0.08)
      end
      
      if distant_amp > 0
        with_fx :hpf, cutoff: 70 do
          with_fx :lpf, cutoff: rrand(85, 95) do
            with_fx :reverb, room: 0.8, mix: 0.6, damp: 0.4 do
              with_fx :echo, phase: 1.5, decay: 8.0, mix: 0.3 do
                if one_in(12)
                  bell_type = choose([:main, :light, :karan])
                  case bell_type
                  when :main
                    sample bell_main, amp: distant_amp * rrand(1.0, 1.4), rate: rrand(0.85, 0.95), pan: rrand(-0.6, 0.6), attack: rrand(0.05, 0.15), release: rrand(2.0, 4.0)
                  when :light
                    sample bell_light, amp: distant_amp * rrand(0.9, 1.2), rate: rrand(0.9, 1.0), pan: rrand(-0.4, 0.4), attack: rrand(0.08, 0.2), release: rrand(1.5, 3.0)
                  when :karan
                    sample karankoron, amp: distant_amp * rrand(0.8, 1.1), rate: rrand(0.8, 0.9), pan: rrand(-0.3, 0.5), attack: rrand(0.1, 0.25), release: rrand(1.0, 2.5)
                  end
                end
                sleep rrand(2.0, 4.0)
              end
            end
          end
        end
      else; stop; end
    end
  end; end

# ===== 追加音源（taiga-sentou, ame, maybe-back） =====
live_loop :extra_sounds do; sleep 10; t = vt
  if t >= sec(600) && t < sec(610); sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/taiga-sentou.mp3", amp: rrand(0.15, 0.25), rate: rrand(0.95, 1.05); end
  if t > sec(10) && one_in(970); with_fx :reverb, room: 0.4, mix: 0.3 do; sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/ame.mp3", amp: rrand(0.12, 0.18), rate: rrand(0.9, 1.1); end; end
  if t >= sec(960) && t < sec(970); with_fx :reverb, room: 0.5, mix: 0.4 do; sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/maybe-back.mp3", amp: rrand(0.18, 0.28); end; end
end


# ===== 進行表示 =====
live_loop :progress_display do; sleep 10; elapsed = vt.to_i; puts "=== 経過時間: #{elapsed}秒 ==="
  if elapsed < 60; puts "Phase 1: 自然な歩行（テンポ不安定）"
  elsif elapsed < 120; puts "Phase 2: 少しリズミカルに（テンポ安定化）"
  elsif elapsed < 240; puts "Phase 3: ビートに近づく（テンポ同期・アクセント追加）"
  elsif elapsed < 300; puts "Phase 4: 歩行音の音量調整（ビート準備）"
  elsif elapsed < 330; puts "Phase 5a: キック登場（控えめに刻む）"
  elsif elapsed < 360; puts "Phase 5b: キック + ハイハット登場"
  elsif elapsed < 420; puts "Phase 5c: フルビート完成（オープンハット追加）"
  elsif elapsed < 600; puts "Phase 6: ビートと歩行の最終共存"
  elsif elapsed < 1020; puts "Phase 7: 安定した共存状態"
  elsif elapsed < 1080; puts "Phase 8: 寺院ドローン開始（トリップ感の始まり）"
  elsif elapsed < 1140; puts "Phase 9: メロディックドローン追加（歩行・ビートフェードアウト）"
  elsif elapsed < 1200; puts "Phase 10: 高音きらめき追加（完全な寺院移行）"
  else; puts "Phase 11: 幻想的な寺院の世界（完全トリップ状態）"; end
end

# ===== PART 2: 寺院の幻想（20分後から開始） =====
# Voice Samples（20分後から開始）
live_loop :voice_samples do
  sleep sec(1200)  # 20分待機
  loop do
    sleep rrand(5, 10)
    voice_choice = rrand_i(1, 3)
    
    with_fx :reverb, room: 0.9, mix: 0.8, damp: 0.2 do
      with_fx :echo, phase: rrand(2.0, 4.0), decay: rrand(8, 12), mix: 0.6 do
        with_fx :pitch_shift, pitch: rrand(-0.3, 0.3), mix: 0.4 do
          with_fx :lpf, cutoff: rrand(70, 100), res: 0.3 do
            case voice_choice
            when 1
              sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/roma-master-voice.mp3",
                amp: rrand(0.12, 0.20), pan: rrand(-0.4, 0.4), rate: rrand(0.8, 1.2)
            when 2
              sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/roba-master-yeah-hosse.mp3",
                amp: rrand(0.06, 0.12), pan: rrand(-0.5, 0.5), rate: rrand(0.7, 1.1)
            when 3
              sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/nigen-sannin.mp3",
                amp: rrand(0.20, 0.40), pan: rrand(-0.6, 0.6), rate: rrand(0.6, 1.3)
            end
          end
        end
      end
    end
  end
end

# ===== 寺院への段階的トリップ（17分から徐々に開始） =====
# 寺院ドローン（17分からフェードイン開始）
temple_wait = sec(1020); temple_fade = 180; temple_lvl = 0.6
with_fx :level, amp: 0 do |fx_temple|
  in_thread do; sleep temple_wait; fade_to fx_temple, temple_lvl, temple_fade; end
  
  live_loop :temple_drone do; sleep temple_wait
    loop do
      with_fx :reverb, room: 0.95, mix: 0.85, damp: 0.1 do
        with_fx :echo, phase: rrand(1.0, 3.0), decay: rrand(10, 15), mix: 0.7 do
          with_fx :pitch_shift, pitch: rrand(-0.1, 0.1), mix: 0.3 do
            with_fx :lpf, cutoff: rrand(60, 80), res: 0.4 do
              use_synth :hollow
              base_note = choose([:c2, :f2, :g2])
              play base_note, amp: rrand(0.3, 0.5),
                attack: rrand(6, 12), sustain: rrand(12, 20), release: rrand(8, 15),
                cutoff: rrand(50, 70), pan: rrand(-0.1, 0.1)
              sleep rrand(28, 36)
            end
          end
        end
      end
    end
  end; end

# メロディックドローン（18分から開始）
with_fx :level, amp: 0 do |fx_melody|
  in_thread do; sleep sec(1080); fade_to fx_melody, 0.4, 120; end
  
  live_loop :temple_melody do; sleep sec(1080)
    loop do
      notes = [:c3, :db3, :e3, :f3, :g3, :ab3, :bb3, :c4]
      with_fx :reverb, room: 0.8, mix: 0.6, damp: 0.4 do
        with_fx :echo, phase: 2.0, decay: 6, mix: 0.3 do
          with_fx :hpf, cutoff: rrand(40, 60) do
            with_fx :lpf, cutoff: rrand(80, 95), res: 0.4 do
              use_synth :prophet
              4.times do
                note = notes.choose
                play note, amp: rrand(0.18, 0.22),
                  attack: rrand(4, 7), sustain: rrand(10, 14), release: rrand(6, 10),
                  cutoff: rrand(70, 85), res: 0.3, pan: rrand(-0.3, 0.3)
                sleep rrand(8, 16)
              end
            end
          end
        end
      end
    end
  end; end

# 高音のきらめき（19分から開始）
with_fx :level, amp: 0 do |fx_shimmer|
  in_thread do; sleep sec(1140); fade_to fx_shimmer, 0.3, 60; end
  
  live_loop :temple_shimmer do; sleep sec(1140)
    loop do
      with_fx :reverb, room: 0.98, mix: 0.9, damp: 0.1 do
        with_fx :echo, phase: rrand(2.5, 5.0), decay: rrand(12, 18), mix: 0.8 do
          with_fx :pitch_shift, pitch: rrand(-0.5, 0.5), mix: 0.6 do
            with_fx :hpf, cutoff: rrand(80, 120) do
              use_synth :sine
              if one_in(2)
                harmonics = [:c4, :e4, :g4, :c5, :e5, :g5, :c6, :e6]
                note = harmonics.choose
                play note, amp: rrand(0.05, 0.12),
                  attack: rrand(1, 6), sustain: rrand(3, 12), release: rrand(8, 20),
                  pan: rrand(-0.8, 0.8), cutoff: rrand(90, 130)
                
                if one_in(4)
                  harmony_note = note + 7
                  play harmony_note, amp: rrand(0.03, 0.08),
                    attack: rrand(2, 8), sustain: rrand(4, 10), release: rrand(10, 25),
                    pan: rrand(-0.6, 0.6), cutoff: rrand(100, 140)
                end
              end
              sleep rrand(8, 20)
            end
          end
        end
      end
    end
  end; end