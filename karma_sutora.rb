#### KARMA SUTORA ####
use_bpm 100

# ===== Helpers =====
define :sec do |s| s.to_f * (current_bpm/60.0) end

define :fade_to do |fx, to_amp, secs=8, steps=12, key=:amp_mem|
  from=get(key)||0.0; d=(to_amp-from)/steps.to_f
  steps.times do |i|
    a=from+d*(i+1); control fx, amp:a; set key,a
    sleep sec(secs/steps.to_f)
  end
end

# ===== Voice Samples (ランダム定期再生) =====
live_loop :voice_samples do
  # 5-10秒のランダム間隔で待機
  sleep rrand(30, 90)
  
  # 3つのボイスからランダムに選択
  voice_choice = rrand_i(1, 3)
  
  # 幻想的なエフェクトでボイスを包む
  with_fx :reverb, room: 0.9, mix: 0.8, damp: 0.2 do
    with_fx :echo, phase: rrand(2.0, 4.0), decay: rrand(8, 12), mix: 0.6 do
      with_fx :pitch_shift, pitch: rrand(-0.3, 0.3), mix: 0.4 do
        with_fx :lpf, cutoff: rrand(70, 100), res: 0.3 do
          case voice_choice
          when 1
            # Roma Master Voice - 神秘的に
            sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/roma-master-voice.mp3",
              amp: rrand(0.12, 0.20),
              pan: rrand(-0.4, 0.4),
              rate: rrand(0.8, 1.2)
          when 2
            # Roba Master Yeah Hosse - 幽玄に
            sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/roba-master-yeah-hosse.mp3",
              amp: rrand(0.14, 0.23),
              pan: rrand(-0.5, 0.5),
              rate: rrand(0.7, 1.1)
          when 3
            # Ningen Sanin - 幻想的に
            sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/nigen-sannin.mp3",
              amp: rrand(0.20, 0.40),
              pan: rrand(-0.6, 0.6),
              rate: rrand(0.6, 1.3)
          when 4
            # Kamide Kumada Voice - 神秘的に
            sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/kamide-kumada.mp3",
              amp: rrand(0.12, 0.20),
              pan: rrand(-0.4, 0.4),
              rate: rrand(0.8, 1.2)
          end
        end
      end
    end
  end
end

# ===== Indian Temple Synth (幻想的な寺院の音) =====
temple_wait=1; temple_fade=15; temple_lvl=0.6
with_fx :level, amp:0 do |fx_temple|
  in_thread do
    sleep temple_wait; fade_to fx_temple, temple_lvl, temple_fade, 16, :temple_amp
  end
  
  # メインドローン（低音の持続音）- より幻想的に
  live_loop :temple_drone do
    with_fx :reverb, room: 0.95, mix: 0.85, damp: 0.1 do
      with_fx :echo, phase: rrand(1.0, 3.0), decay: rrand(10, 15), mix: 0.7 do
        with_fx :pitch_shift, pitch: rrand(-0.1, 0.1), mix: 0.3 do
          with_fx :lpf, cutoff: rrand(60, 80), res: 0.4 do
            use_synth :hollow
            # 時々異なる音程を混ぜる
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
  
  # メロディックドローン（インド風スケール）
  live_loop :temple_melody do
    # インドのラーガ風スケール（ミクソリディアン＋フラット2度）
    notes = [:c3, :db3, :e3, :f3, :g3, :ab3, :bb3, :c4]
    
    with_fx :reverb, room: 0.8, mix: 0.6, damp: 0.4 do
      with_fx :echo, phase: 2.0, decay: 6, mix: 0.3 do
        with_fx :hpf, cutoff: rrand(40, 60) do
          with_fx :lpf, cutoff: rrand(80, 95), res: 0.4 do
            use_synth :prophet
            
            # ゆったりとしたメロディー
            4.times do
              note = notes.choose
              play note, amp: rrand(0.18, 0.22),
                attack: rrand(4, 7), sustain: rrand(10, 14), release: rrand(6, 10),
                cutoff: rrand(70, 85), res: 0.3,
                pan: rrand(-0.3, 0.3)
              sleep rrand(8, 16)
            end
          end
        end
      end
    end
  end
  
  # 高音のきらめき（遠くの鐘のような）- 超幻想的に
  live_loop :temple_shimmer do
    with_fx :reverb, room: 0.98, mix: 0.9, damp: 0.1 do
      with_fx :echo, phase: rrand(2.5, 5.0), decay: rrand(12, 18), mix: 0.8 do
        with_fx :pitch_shift, pitch: rrand(-0.5, 0.5), mix: 0.6 do
          with_fx :hpf, cutoff: rrand(80, 120) do
            use_synth :sine
            
            if one_in(2)  # より頻繁に鳴らす
              # より広い音域とハーモニクス
              harmonics = [:c4, :e4, :g4, :c5, :e5, :g5, :c6, :e6]
              note = harmonics.choose
              play note, amp: rrand(0.05, 0.12),
                attack: rrand(1, 6), sustain: rrand(3, 12), release: rrand(8, 20),
                pan: rrand(-0.8, 0.8),
                cutoff: rrand(90, 130)
              
              # 時々ハーモニーを追加
              if one_in(4)
                harmony_note = note + 7  # 5度上
                play harmony_note, amp: rrand(0.03, 0.08),
                  attack: rrand(2, 8), sustain: rrand(4, 10), release: rrand(10, 25),
                  pan: rrand(-0.6, 0.6),
                  cutoff: rrand(100, 140)
              end
            end
            
            sleep rrand(8, 20)
          end
        end
      end
    end
  end