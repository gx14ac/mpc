use_bpm 90
define :sec do |s|; s * (60.0 / current_bpm); end
define :swing do |n|; n % 2 == 0 ? n : n + 0.05; end
define :fade_to do |fx, amp, fade|; (fade * 4).times { |i| control fx, amp: amp * (i + 1) / (fade * 4).to_f; sleep sec(fade) / (fade * 4) }; end

# ===== ヒップホップ・キック =====
live_loop :hiphop_kick do
  16.times do |i|
    if [0, 6, 12].include?(i)
      # メインキック
      sample :bd_boom, amp: rrand(0.8, 1.0), rate: rrand(0.95, 1.05)
    elsif [4, 10].include?(i) && one_in(3)
      # サブキック
      sample :bd_808, amp: rrand(0.4, 0.6), rate: rrand(0.9, 1.1)
    end
    sleep swing(0.25)
  end
end

# ===== ヒップホップ・スネア =====
with_fx :level, amp: 0 do |fx_snare|; in_thread do; sleep sec(2); fade_to fx_snare, 0.7, 2; end
  live_loop :hiphop_snare do
    16.times do |i|
      if [4, 12].include?(i)
        # メインスネア
        with_fx :reverb, room: 0.3, mix: 0.2 do
          sample :sn_dub, amp: rrand(0.7, 0.9), rate: rrand(0.98, 1.02)
        end
      elsif [6, 14].include?(i) && one_in(4)
        # ゴーストスネア
        sample :sn_generic, amp: rrand(0.2, 0.4), rate: rrand(1.1, 1.3)
      end
      sleep swing(0.25)
    end
end; end

# ===== ハイハット =====
with_fx :level, amp: 0 do |fx_hats|; in_thread do; sleep sec(4); fade_to fx_hats, 0.5, 2; end
  live_loop :hiphop_hats do
    16.times do |i|
      if i % 2 == 1
        # オフビートハイハット
        sample :drum_cymbal_closed, amp: rrand(0.3, 0.5), rate: rrand(1.0, 1.2),
          pan: rrand(-0.2, 0.2)
      elsif [2, 10].include?(i) && one_in(3)
        # アクセントハイハット
        sample :drum_cymbal_open, amp: rrand(0.2, 0.3), rate: rrand(0.9, 1.1),
          finish: rrand(0.3, 0.5), pan: rrand(-0.3, 0.3)
      end
      sleep swing(0.25)
    end
end; end

# ===== ヒップホップ・パーカッション =====
with_fx :level, amp: 0 do |fx_perc|; in_thread do; sleep sec(12); fade_to fx_perc, 0.4, 3; end
  live_loop :hiphop_percussion do
    16.times do |i|
      case i
      when 3, 7, 11, 15
        if one_in(2)
          sample :perc_snap, amp: rrand(0.2, 0.4), rate: rrand(0.8, 1.2),
            pan: rrand(-0.4, 0.4)
        end
      when 1, 9
        if one_in(4)
          sample :drum_tom_lo_soft, amp: rrand(0.3, 0.5), rate: rrand(0.9, 1.1),
            pan: rrand(-0.3, 0.3)
        end
      end
      sleep swing(0.25)
    end
end; end

in_thread do
  sleep sec(4)
  1.times do
    sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/俺もラップやってミテェ.mp3",
      amp: 1.0,
      rate: 1.0,
      pan: 0
  end
end

in_thread do
  sleep sec(12)
  3.times do
    sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/AH.mp3",
      amp: 1.0,
      rate: 1.0,
      pan: 0
    sleep 2.5
  end
end

in_thread do
  sleep sec(29)
  1.times do
    sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/アラスカきて.mp3",
      amp: 1.0,
      rate: 1.0,
      pan: 0
  end
end

in_thread do
  sleep sec(32)
  1.times do
    sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/ときめき.mp3",
      amp: 1.5,
      rate: 1.0,
      pan: 0
  end
end