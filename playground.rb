use_bpm 100

# ===== Piano V3 (フェードインで開始) =====
piano_wait=0; piano_fade=30; piano_lvl=0.15
with_fx :level, amp:0 do |fx_piano|
  in_thread do
    sleep piano_wait; fade_to fx_piano, piano_lvl, piano_fade
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

# ===== Ambient Bass Hybrid (段階的フェードイン) =====
bass_wait=15; bass_fade=45; bass_lvl=0.08
with_fx :level, amp:0 do |fx_bass|
  in_thread do
    sleep bass_wait; fade_to fx_bass, bass_lvl, bass_fade
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
