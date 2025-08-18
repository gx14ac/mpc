use_bpm 105

# ===== Helper Functions =====
define :sec do |s|; s * (60.0 / current_bpm); end
define :fade_to do |fx, amp, fade|
  (fade * 4).times { |i| control fx, amp: amp * (i + 1) / (fade * 4).to_f; sleep sec(fade) / (fade * 4) }
end

# ===== Timeline & Fade Setup =====
[[0, :kick, 0.8, 0], [8, :snare, 0.7, 4], [16, :hats, 0.6, 3], [32, :bass, 0.7, 8], [48, :sub, 0.5, 6], [64, :vocal, 0.5, 4], [80, :taiga, 0.6, 5], [96, :melody, 0.4, 6], [112, :extra, 0.3, 4]].each do |time, name, amp, fade|
  in_thread do
    sleep sec(time)
    if fade > 0
      with_fx :level, amp: 0 do |fx|; fade_to fx, amp, fade; end
    end
  end
end

# ===== シンプルで気持ちいい8ビート =====
live_loop :kick do
  # 1拍目と3拍目のシンプルキック（重低音抑制）
  8.times do |i|
    if [0, 4].include?(i)  # 1拍目と3拍目
      # 重低音をカットしてパンチのあるキック
      with_fx :hpf, cutoff: 60, res: 0.2 do  # 60Hz以下をカット
        sample :bd_tek, 
          amp: rrand(0.6, 0.8),  # 音量を少し下げる
          rate: rrand(0.99, 1.01),  # 安定感
          cutoff: rrand(100, 120),  # 高域寄りでパンチ
          pan: rrand(-0.05, 0.05)
      end
    elsif one_in(32)  # 稀にアクセント
      with_fx :hpf, cutoff: 50, res: 0.1 do
        sample :bd_tek, 
          amp: 0.4,  # アクセントも控えめに
          rate: rrand(0.98, 1.02), 
          cutoff: rrand(90, 110)
      end
    end
    sleep 0.5
  end
end

# ===== Snare (8秒後フェードイン) =====
with_fx :level, amp: 0 do |fx_snare|
  in_thread do
    sleep sec(8); fade_to fx_snare, 0.4, 4  # 音量を下げる
  end
  
  live_loop :snare do
    # 2拍目と4拍目のクラシックスネア
    8.times do |i|
      if [2, 6].include?(i)  # 2拍目と4拍目
        if one_in(16)  # 稀にリバーブ
          with_fx :reverb, room: 0.3, mix: 0.2 do
            sample :sn_dub,
              amp: rrand(0.4, 0.6),  # 音量を下げる
              rate: rrand(0.99, 1.01),
              cutoff: rrand(100, 120),
              pan: rrand(-0.1, 0.1)
          end
        else
          # 基本のスネア
          sample :sn_dub,
            amp: rrand(0.5, 0.7),  # 音量を大幅に下げる
            rate: rrand(0.99, 1.01),
            cutoff: rrand(95, 115),
            pan: rrand(-0.05, 0.05)
        end
      elsif one_in(24)  # 稀にゴーストノート
        sample :sn_dub,
          amp: rrand(0.15, 0.25),  # ゴーストノートも下げる
          rate: rrand(0.98, 1.02),
          cutoff: rrand(85, 105),
          pan: rrand(-0.15, 0.15)
      end
      sleep 0.5
    end
  end
end

# ===== Hi-Hats (16秒後フェードイン) =====
with_fx :level, amp: 0 do |fx_hats|
  in_thread do
    sleep sec(16); fade_to fx_hats, 0.4, 3  # 全体音量を下げる
  end
  
  live_loop :hats do
    # 8分音符の気持ちいいハイハット
    8.times do |i|
      # オフビート（裏拍）を少し強調
      amp = (i % 2 == 1) ? rrand(0.3, 0.4) : rrand(0.25, 0.35)  # 音量を下げる
      
      if one_in(20)  # 稀にオープンハット
        sample :drum_cymbal_open, 
          amp: amp * 0.6,  # さらに控えめに
          rate: rrand(0.99, 1.01),
          finish: rrand(0.4, 0.6),
          pan: rrand(-0.4, 0.4)
      else
        # 基本のクローズドハット
        sample :drum_cymbal_closed, 
          amp: amp,
          rate: rrand(0.99, 1.01),
          finish: rrand(0.3, 0.5),
          cutoff: rrand(110, 130),
          pan: rrand(-0.2, 0.2)
      end
      sleep 0.5
    end
  end
end
##| ===== Bass (32秒後ゆっくりフェードイン) =====
with_fx :level, amp: 0 do |fx_bass|
    in_thread do
      sleep sec(32); fade_to fx_bass, 0.7, 8  # 8秒かけてゆっくりフェードイン
    end
    
    live_loop :bass do
      use_synth :fm
      [:c2, :c2, :eb2, :f2, :g2, :f2, :eb2, :c2].zip([1,0,1,0,1,1,0,1,1,0,0,1,1,0,1,0] * 2).each do |note, hit|
        if hit == 1
          play note, amp: rrand(0.1, 0.3), divisor: rrand(1.8, 2.2), depth: rrand(0.8, 1.2),
            attack: 0.01, release: rrand(0.3, 0.6), cutoff: rrand(70, 90), res: rrand(0.3, 0.6)
        end
        sleep 0.25
      end
    end
  end
  
  ##| ===== Sub Bass (48秒後さらにゆっくり) =====
  with_fx :level, amp: 0 do |fx_sub|
    in_thread do
      sleep sec(48); fade_to fx_sub, 0.5, 6  # 6秒かけてフェードイン
    end
    
    live_loop :sub_bass do
      use_synth :subpulse
      [1,0,0,0,1,0,1,0,1,0,0,0,1,0,0,1].each do |hit|
        if hit == 1
          play [:c1, :eb1, :f1, :g1].choose, amp: rrand(0.4, 0.6), pulse_width: rrand(0.1, 0.3),
            cutoff: rrand(40, 60), res: rrand(0.2, 0.4), attack: 0.05, release: rrand(0.8, 1.2)
        end
        sleep 0.5
      end
    end
  end

# ===== Vocals & Effects =====
with_fx :level, amp: 0 do |fx_vocal|
  in_thread do
    sleep sec(64); fade_to fx_vocal, 0.5, 4
  end
  
  live_loop :walk_zakuzaku do
    sleep rrand(15, 30)  # 頻度を戻す
    if one_in(3)
      sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/walk-zakuzaku.mp3",
        amp: rrand(0.4, 0.6),  # 音量を普通に戻す
        rate: rrand(0.9, 1.1), 
        pan: rrand(-0.6, 0.6), 
        cutoff: rrand(80, 110)
    end
  end
end

with_fx :level, amp: 0 do |fx_taiga|
  in_thread do
    sleep sec(80); fade_to fx_taiga, 0.6, 5
  end
  
  live_loop :taiga_ningen do
    sleep rrand(8, 20)  # 頻度を戻す
    if one_in(3)
      with_fx :reverb, room: 0.6, mix: 0.4, damp: 0.5 do
        with_fx :hpf, cutoff: 80, res: 0.2 do
          sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/taiga-ningen.mp3",
            amp: rrand(0.6, 0.9),  # 音量を普通に戻す
            rate: rrand(0.95, 1.05), 
            start: rrand(0, 0.1), 
            finish: rrand(0.9, 1),
            attack: rrand(0.1, 0.3), 
            release: rrand(1, 2), 
            pan: rrand(-0.3, 0.3), 
            cutoff: rrand(100, 130)
        end
      end
    end
  end
end

with_fx :level, amp: 0 do |fx_extra|
  in_thread do
    sleep sec(112); fade_to fx_extra, 0.3, 4
  end
  
  live_loop :extra_effects do
    sleep rrand(2, 8)  # 頻度を戻す
    case rrand_i(1, 2)
    when 1  # Breakbeat
      if one_in(8)
        4.times { sample :loop_amen, amp: 0.6, rate: rrand(0.8, 1.2), pan: rrand(-0.4, 0.4); sleep 0.125 }
      end
    when 2  # Glitch
      with_fx :bitcrusher, bits: rrand(4, 8) do
        sample [:perc_snap, :perc_snap2, :drum_tom_lo_soft].choose,
          amp: rrand(0.3, 0.6),  # 音量を普通に戻す
          rate: rrand(0.5, 2.0), 
          pan: rrand(-0.8, 0.8)
      end
    end
  end
end
