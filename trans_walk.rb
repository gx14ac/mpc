# ===== TRANS.RB - 歩行からビートへの自然な進化（短縮版） =====
use_bpm 100
define :sec do |s|; s * (60.0 / current_bpm); end
define :fade_to do |fx, amp, fade_time|; (fade_time * 4).times { |i| control fx, amp: amp * (i + 1) / (fade_time * 4).to_f; sleep fade_time / (fade_time * 4) }; end

# ===== イントロ：intro.mp3を一度だけ再生 =====
intro_duration = 15  # intro.mp3の長さ（秒）を設定
sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/intro.mp3", amp: 0.8

# イントロ終了まで待機
sleep intro_duration

# ===== 歩行の進化（イントロ後に開始） =====
live_loop :walking_evolution do
  time_elapsed = vt - intro_duration  # イントロ分の時間を差し引く
  
  if time_elapsed < sec(30)  # Phase 1: 最初の30秒だけzakuzaku
    base_interval = rrand(1.2, 2.8)
    base_interval *= rrand(1.5, 2.5) if one_in(8)  # 立ち止まり
    base_interval *= rrand(0.4, 0.7) if one_in(6)  # 急ぎ足
    sleep base_interval
    sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/walk-zakuzaku.mp3", amp: rrand(0.12, 0.22), rate: rrand(0.9, 1.1), pan: rrand(-0.1, 0.1), cutoff: rrand(75, 90), attack: rrand(0.02, 0.08), release: rrand(0.2, 0.5)
    
  else  # Phase 2: 30秒後は停止
    sleep 10  # 長い待機時間で実質的に停止
  end
end

with_fx :level, amp: 0 do |fx_kick|; in_thread do; sleep intro_duration + sec(10); fade_to fx_kick, 1.1, 20; end; live_loop :kick do; sleep intro_duration + sec(10); loop do; sample :bd_boom, amp: 0.45, cutoff: 70, attack: 0.01, release: 0.8; sleep 3; sample :bd_boom, amp: 0.38, cutoff: 75, attack: 0.01, release: 0.6; sleep 3; end; end; end
with_fx :level, amp: 0 do |fx_hats|; in_thread do; sleep intro_duration + sec(20); fade_to fx_hats, 0.6, 15; end; live_loop :hats do; sleep intro_duration + sec(20); loop do; sample :drum_cymbal_soft, amp: 0.12, sustain: 0.02, release: 0.15, cutoff: 100; sleep 0.75; sample :drum_cymbal_soft, amp: 0.08, sustain: 0.01, release: 0.12, cutoff: 95; sleep 0.75; end; end; end
with_fx :level, amp: 0 do |fx_snare|; in_thread do; sleep intro_duration + sec(30); fade_to fx_snare, 0.8, 15; end; live_loop :snare do; sleep intro_duration + sec(30); loop do; sleep 1.5; sample :sn_generic, amp: 0.32, cutoff: 80, attack: 0.01, release: 0.4; sleep 1.5; end; end; end

# ===== 遠くのベル（キック登場と同時） =====
bell_main = "/Users/shinta/git/github.com/gx14ac/mpc/assets/ring-roba.mp3"
bell_light = "/Users/shinta/git/github.com/gx14ac/mpc/assets/roba-light-ring.mp3"
karankoron = "/Users/shinta/git/github.com/gx14ac/mpc/assets/karankoron.mp3"

with_fx :level, amp: 0 do |fx_bells|; in_thread do; sleep intro_duration + sec(10); fade_to fx_bells, 0.6, 20; end
  live_loop :distant_bells do; sleep intro_duration + sec(10)
    loop do
      time_elapsed = vt
      bell_time = time_elapsed - sec(10)
      
      # 遠くから聞こえる感じの設定（音量アップ）
      distant_amp = 0.18 + (bell_time / sec(120) * 0.12)  # 徐々に少し大きく
      
      with_fx :hpf, cutoff: 70 do
        with_fx :lpf, cutoff: rrand(85, 95) do  # 高音をカット
          with_fx :reverb, room: 0.8, mix: 0.6, damp: 0.4 do  # 大きなリバーブ
            with_fx :echo, phase: 1.5, decay: 8.0, mix: 0.3 do  # 長いエコー
              
              # たまに鳴らす（確率的に）
              if one_in(12)  # 約8%の確率
                bell_type = choose([:main, :light, :karan])
                
                case bell_type
                when :main
                  sample bell_main, amp: distant_amp * rrand(1.2, 1.6),
                    rate: rrand(0.85, 0.95), pan: rrand(-0.6, 0.6),
                    attack: rrand(0.05, 0.15), release: rrand(2.0, 4.0)
                when :light
                  sample bell_light, amp: distant_amp * rrand(1.1, 1.4),
                    rate: rrand(0.9, 1.0), pan: rrand(-0.4, 0.4),
                    attack: rrand(0.08, 0.2), release: rrand(1.5, 3.0)
                when :karan
                  sample karankoron, amp: distant_amp * rrand(1.0, 1.3),
                    rate: rrand(0.8, 0.9), pan: rrand(-0.3, 0.5),
                    attack: rrand(0.1, 0.25), release: rrand(1.0, 2.5)
                end
              end
              
              sleep rrand(2.0, 4.0)  # ランダムな間隔
            end
          end
        end
      end
    end
end; end

live_loop :extra_sounds do; sleep intro_duration + 10; t = vt - intro_duration
  if t >= sec(120) && t < sec(130); sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/taiga-sentou.mp3", amp: rrand(0.22, 0.35), rate: rrand(0.95, 1.05); end
  if t > sec(10) && one_in(5); with_fx :reverb, room: 0.4, mix: 0.3 do; sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/ame.mp3", amp: rrand(0.18, 0.26), rate: rrand(0.9, 1.1); end; end
  if t >= sec(200) && t < sec(210); with_fx :reverb, room: 0.5, mix: 0.4 do; sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/maybe-back.mp3", amp: rrand(0.25, 0.38); end; end
end

## trans_walkで後から入れる。
# ===== Piano V3 (フェードインで開始) =====
piano_wait=120; piano_fade=30; piano_lvl=0.15
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
bass_wait=120; bass_fade=45; bass_lvl=0.2
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