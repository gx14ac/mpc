use_bpm 105
define :sec do |s|; s * (60.0 / current_bpm); end
define :fade_to do |fx, amp, fade|; (fade * 4).times { |i| control fx, amp: amp * (i + 1) / (fade * 4).to_f; sleep sec(fade) / (fade * 4) }; end

# ===== 歩く音（一度だけ） =====
in_thread do
  with_fx :reverb, room: 0.3, mix: 0.2 do
    with_fx :lpf, cutoff: 100 do
      sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/walk-zakuzaku.mp3",
        amp: 0.7,
        rate: 1.0,
        pan: 0
    end
  end
end

# ===== 人間とおります（8秒後に一度だけ） =====
in_thread do
  sleep sec(8)
  with_fx :reverb, room: 0.8, mix: 0.7, damp: 0.4 do
    with_fx :echo, phase: 1.5, decay: 6, mix: 0.5 do
      with_fx :lpf, cutoff: 120 do
        sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/taiga-ningen.mp3",
          amp: 0.8,
          rate: 1.0,
          attack: 0.3,
          release: 3,
          pan: 0
      end
    end
  end
end

# Timeline: [time, amp, fade]
[[0, 0.8, 0], [8, 0.4, 4], [16, 0.4, 3], [32, 0.7, 8], [48, 0.5, 6], [64, 0.5, 4], [80, 0.6, 5], [112, 0.3, 4]].each_with_index do |(time, amp, fade), i|
  in_thread do; sleep sec(time); with_fx :level, amp: 0 do |fx|; fade_to fx, amp, fade if fade > 0; end; end if i > 0
end

# Drums
live_loop :kick do; 8.times { |i| with_fx :hpf, cutoff: 60, res: 0.2 do; sample :bd_tek, amp: rrand(0.6, 0.8), rate: rrand(0.99, 1.01), cutoff: rrand(100, 120); end if [0, 4].include?(i) || one_in(32); sleep 0.5 }; end

with_fx :level, amp: 0 do |fx_snare|; in_thread do; sleep sec(8); fade_to fx_snare, 0.4, 4; end
live_loop :snare do; 8.times { |i| if [2, 6].include?(i); (one_in(16) ? (with_fx :reverb, room: 0.3, mix: 0.2 do; sample :sn_dub, amp: rrand(0.4, 0.6), rate: rrand(0.99, 1.01), cutoff: rrand(100, 120); end) : (sample :sn_dub, amp: rrand(0.5, 0.7), rate: rrand(0.99, 1.01), cutoff: rrand(95, 115))); elsif one_in(24); sample :sn_dub, amp: rrand(0.15, 0.25), rate: rrand(0.98, 1.02), cutoff: rrand(85, 105); end; sleep 0.5 }; end; end

with_fx :level, amp: 0 do |fx_hats|; in_thread do; sleep sec(16); fade_to fx_hats, 0.4, 3; end
live_loop :hats do; 8.times { |i| amp = (i % 2 == 1) ? rrand(0.3, 0.4) : rrand(0.25, 0.35); (one_in(20) ? (sample :drum_cymbal_open, amp: amp * 0.6, rate: rrand(0.99, 1.01), finish: rrand(0.4, 0.6), pan: rrand(-0.4, 0.4)) : (sample :drum_cymbal_closed, amp: amp, rate: rrand(0.99, 1.01), finish: rrand(0.3, 0.5), cutoff: rrand(110, 130), pan: rrand(-0.2, 0.2))); sleep 0.5 }; end; end

# Bass
with_fx :level, amp: 0 do |fx_bass|; in_thread do; sleep sec(32); fade_to fx_bass, 1.2, 8; end
live_loop :bass do; use_synth :fm; [:c2, :c2, :eb2, :f2, :g2, :f2, :eb2, :c2].zip([1,0,1,0,1,1,0,1,1,0,0,1,1,0,1,0] * 2).each { |note, hit| play note, amp: rrand(0.5, 0.7), divisor: rrand(1.8, 2.2), depth: rrand(0.8, 1.2), attack: 0.01, release: rrand(0.4, 0.7), cutoff: rrand(85, 105), res: rrand(0.1, 0.3) if hit == 1; sleep 0.25 }; end; end

with_fx :level, amp: 0 do |fx_sub|; in_thread do; sleep sec(48); fade_to fx_sub, 0.8, 6; end
live_loop :sub_bass do; use_synth :subpulse; [1,0,0,0,1,0,1,0,1,0,0,0,1,0,0,1].each { |hit| play [:c1, :eb1, :f1, :g1].choose, amp: rrand(0.6, 0.7), pulse_width: rrand(0.1, 0.3), cutoff: rrand(50, 70), res: rrand(0.1, 0.2), attack: 0.05, release: rrand(0.8, 1.2) if hit == 1; sleep 0.5 }; end; end

# Effects
with_fx :level, amp: 0 do |fx_vocal|; in_thread do; sleep sec(64); fade_to fx_vocal, 0.5, 4; end
live_loop :walk_zakuzaku do; sleep rrand(15, 30); sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/walk-zakuzaku.mp3", amp: rrand(0.4, 0.6), rate: rrand(0.9, 1.1), pan: rrand(-0.6, 0.6), cutoff: rrand(80, 110) if one_in(3); end; end

with_fx :level, amp: 0 do |fx_taiga|; in_thread do; sleep sec(0); fade_to fx_taiga, 0.6, 2; end
  live_loop :taiga_ningen do; sleep rrand(8, 20); if one_in(4); case rrand_i(1, 5)
      when 1; with_fx :reverb, room: 0.6, mix: 0.4, damp: 0.5 do; with_fx :hpf, cutoff: 80, res: 0.2 do; sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/taiga-ningen.mp3", amp: rrand(0.6, 0.9), rate: rrand(0.95, 1.05), start: rrand(0, 0.1), finish: rrand(0.9, 1), attack: rrand(0.1, 0.3), release: rrand(1, 2), pan: rrand(-0.3, 0.3), cutoff: rrand(100, 125); end; end
      when 2; with_fx :reverb, room: 0.8, mix: 0.6, damp: 0.3 do; with_fx :echo, phase: 0.75, decay: 4, mix: 0.5 do; with_fx :lpf, cutoff: rrand(90, 120), res: 0.3 do; sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/taiga-ningen.mp3", amp: rrand(0.5, 0.7), rate: rrand(0.9, 1.1), start: rrand(0, 0.2), finish: rrand(0.8, 1), attack: rrand(0.2, 0.5), release: rrand(2, 4), pan: rrand(-0.5, 0.5), cutoff: rrand(80, 120); end; end; end
      when 3; with_fx :pitch_shift, pitch: rrand(-3, 3) do; with_fx :flanger, phase: rrand(2, 6), decay: 4, mix: 0.4 do; with_fx :reverb, room: 0.5, mix: 0.3 do; sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/taiga-ningen.mp3", amp: rrand(0.4, 0.6), rate: rrand(0.85, 1.15), start: rrand(0, 0.15), finish: rrand(0.85, 1), attack: rrand(0.3, 0.7), release: rrand(1.5, 3), pan: rrand(-0.4, 0.4), cutoff: rrand(90, 125); end; end; end
      when 4; with_fx :bitcrusher, bits: rrand(6, 10), sample_rate: rrand(8000, 16000) do; with_fx :wobble, phase: rrand(1, 4), mix: 0.6 do; with_fx :reverb, room: 0.4, mix: 0.3 do; sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/taiga-ningen.mp3", amp: rrand(0.7, 1.0), rate: rrand(0.8, 1.2), start: rrand(0, 0.1), finish: rrand(0.9, 1), attack: rrand(0.1, 0.4), release: rrand(1, 2.5), pan: rrand(-0.6, 0.6), cutoff: rrand(70, 110); end; end; end
      when 5; with_fx :reverb, room: 0.9, mix: 0.8, damp: 0.1 do; with_fx :echo, phase: 1.5, decay: 6, mix: 0.7 do; with_fx :pitch_shift, pitch: rrand(-7, -3) do; with_fx :lpf, cutoff: rrand(60, 90), res: 0.5 do; sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/taiga-ningen.mp3", amp: rrand(0.3, 0.5), rate: rrand(0.7, 0.9), start: rrand(0, 0.3), finish: rrand(0.7, 1), attack: rrand(0.5, 1.0), release: rrand(3, 6), pan: rrand(-0.7, 0.7), cutoff: rrand(50, 100); end; end; end; end
end; end; end; end

with_fx :level, amp: 0 do |fx_extra|; in_thread do; sleep sec(112); fade_to fx_extra, 0.3, 4; end
live_loop :extra_effects do; sleep rrand(2, 8); (rrand_i(1, 2) == 1) ? (4.times { sample :loop_amen, amp: 0.6, rate: rrand(0.8, 1.2), pan: rrand(-0.4, 0.4); sleep 0.125 } if one_in(8)) : (with_fx :bitcrusher, bits: rrand(4, 8) do; sample [:perc_snap, :perc_snap2, :drum_tom_lo_soft].choose, amp: rrand(0.3, 0.6), rate: rrand(0.5, 1.0), pan: rrand(-0.8, 0.8); end); end; end