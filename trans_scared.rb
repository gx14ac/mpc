# ===== TRANS SCARED - 恐怖テクノ（短縮版） =====
use_bpm 85
define :sec do |s|; s * (60.0 / current_bpm); end

# ===== 心臓音 =====
live_loop :heartbeat do
  beat_interval = choose([1.2, 1.1, 0.9, 1.4, 0.8, 1.3])
  with_fx :reverb, room: 0.5, mix: 0.3 do; with_fx :lpf, cutoff: rrand(55, 70) do
    sample :bd_gas, amp: rrand(0.20, 0.35), rate: rrand(0.6, 0.8), cutoff: rrand(50, 65), release: 0.3, pan: rrand(-0.2, 0.2)
    sleep 0.15; sample :bd_soft, amp: rrand(0.12, 0.22), rate: rrand(0.7, 0.9), cutoff: rrand(60, 75), release: 0.2, pan: rrand(-0.1, 0.1)
  end; end; sleep beat_interval
end

# ===== 背景ノイズ =====
live_loop :blood_flow do
  with_fx :reverb, room: 0.6, mix: 0.4 do; with_fx :lpf, cutoff: rrand(35, 50) do
    use_synth :noise; play :c2, amp: rrand(0.08, 0.15), attack: rrand(3, 6), sustain: rrand(8, 12), release: rrand(5, 8), cutoff: rrand(30, 45), pan: rrand(-0.8, 0.8)
  end; end; sleep rrand(10, 16)
end

# ===== パニック心拍 =====
live_loop :panic_heartbeat do
  t = vt; panic = [t / 45.0, 2.0].min; interval = [1.2 - (panic * 0.4) + rrand(-0.2 - panic * 0.3, 0.2 + panic * 0.3), 0.3].max
  with_fx :reverb, room: 0.4 + panic * 0.1, mix: 0.2 + panic * 0.2 do; with_fx :lpf, cutoff: 70 - panic * 15 do
    sample :bd_boom, amp: 0.15 + panic * 0.20, rate: 0.7 + panic * 0.2, cutoff: 60 - panic * 10, release: 0.2 + panic * 0.1, pan: rrand(-0.3, 0.3)
  end; end; sleep interval
end

# ===== 呼吸音 =====
live_loop :breathing do
  t = vt; stress = [t / 30.0, 2.5].min
  if stress > 0.3
    with_fx :reverb, room: 0.4, mix: 0.2 do; with_fx :hpf, cutoff: 100 + stress * 30 do; with_fx :lpf, cutoff: [80 + stress * 25, 130].min do
      use_synth :noise; play :c4, amp: 0.06 + stress * 0.08, attack: 0.3 + stress * 0.2, sustain: 0.5 + stress * 0.3, release: 0.4 + stress * 0.2, cutoff: [70 + stress * 20, 130].min, pan: rrand(-0.2, 0.2)
      sleep 0.8 + stress * 0.3; play :c3, amp: 0.04 + stress * 0.06, attack: 0.2, sustain: 0.4 + stress * 0.4, release: 0.6 + stress * 0.3, cutoff: [60 + stress * 25, 130].min, pan: rrand(-0.2, 0.2)
    end; end; end
  end; sleep [4.0 - stress * 1.5, 1.5].max + rrand(-0.3, 0.3)
end

# ===== 新しいテクノビート =====
live_loop :dark_kick do; t = vt; if t > 30; intensity = [(t - 30) / 60.0, 1.5].min; with_fx :reverb, room: 0.4, mix: 0.3 do; with_fx :lpf, cutoff: 70 do; sample :bd_boom, amp: 0.55 + intensity * 0.45, rate: 0.7, cutoff: 60, attack: 0.01, release: 0.8; end; end; sleep 1.5; if one_in(8); sample :bd_808, amp: 0.3 + intensity * 0.2, rate: 0.6, cutoff: 55; sleep 0.5; else; sleep 0.5; end; else; sleep 2; end; end

live_loop :industrial_perc do; t = vt; if t > 45; intensity = [(t - 45) / 45.0, 1.0].min; tick; if (look % 4) == 1 || (look % 4) == 3; with_fx :reverb, room: 0.3, mix: 0.2 do; with_fx :lpf, cutoff: 85 do; sample choose([:perc_bell, :drum_tom_lo_soft]), amp: 0.15 + intensity * 0.20, rate: rrand(0.8, 1.2), cutoff: rrand(70, 90), release: rrand(0.1, 0.3), pan: rrand(-0.4, 0.4); end; end; end; sleep 0.75; else; sleep 1; end; end

live_loop :minimal_clap do; t = vt; if t > 60; intensity = [(t - 60) / 30.0, 1.0].min; sleep 2; with_fx :reverb, room: 0.6, mix: 0.4 do; with_fx :lpf, cutoff: 95 do; sample :perc_snap, amp: 0.28 + intensity * 0.32, rate: rrand(0.9, 1.1), cutoff: rrand(80, 100), release: 0.4, pan: rrand(-0.2, 0.2); end; end; if one_in(4); sleep 0.25; sample :perc_snap2, amp: 0.15 + intensity * 0.15, rate: 1.2, cutoff: 70, release: 0.2; sleep 1.75; else; sleep 2; end; else; sleep 4; end; end

live_loop :glitch_perc do; t = vt; if t > 75; intensity = [(t - 75) / 45.0, 1.0].min; if one_in(6); sleep rrand(0.25, 0.75); with_fx :reverb, room: 0.5, mix: 0.3 do; with_fx :lpf, cutoff: rrand(60, 80) do; sample choose([:drum_tom_hi_soft, :perc_till]), amp: 0.18 + intensity * 0.22, rate: rrand(0.5, 1.5), cutoff: rrand(50, 80), release: rrand(0.1, 0.5), pan: rrand(-0.6, 0.6); end; end; sleep rrand(2, 4); else; sleep rrand(3, 6); end; else; sleep 4; end; end

live_loop :dark_bass do; t = vt; if t > 45; level = [(t - 45) / 90.0, 1.0].min; with_fx :reverb, room: 0.5, mix: 0.3 do; with_fx :lpf, cutoff: 60 + level * 20 do; use_synth :fm; play choose([28, 30, 26, 29]), amp: 0.18 + level * 0.25, attack: 0.5 + level * 0.3, sustain: 2 + level, release: 3 + level * 2, cutoff: 50 + level * 15, divisor: 2.5, depth: 0.3 + level * 0.2, pan: rrand(-0.2, 0.2); end; end; sleep 4.8 + rrand(-0.5, 0.5); else; sleep 5; end; end

live_loop :atmosphere do; t = vt; if t > 90; atmos = [(t - 90) / 60.0, 1.0].min; if one_in(10); with_fx :reverb, room: 0.8, mix: 0.6 do; with_fx :lpf, cutoff: rrand(40, 60) do; use_synth :dark_ambience; play choose([24, 26, 28]), amp: 0.08 + atmos * 0.12, attack: rrand(5, 10), sustain: rrand(10, 20), release: rrand(8, 15), cutoff: rrand(35, 55), pan: rrand(-0.8, 0.8); end; end; end; end; sleep rrand(8, 15); end

# ===== ブレイクビーツ =====
live_loop :breakbeat do; t = vt; if t > 60; break_intensity = [(t - 60) / 60.0, 1.0].min; if one_in(12); set :break_active, true; 4.times do; with_fx :reverb, room: 0.3, mix: 0.2 do; with_fx :lpf, cutoff: 90 do; sample :loop_amen, amp: 0.35 + break_intensity * 0.25, rate: choose([1.0, 1.1, 0.9]), beat_stretch: 2, slice: rrand(0, 7), num_slices: 8, cutoff: rrand(80, 100), pan: rrand(-0.3, 0.3); end; end; sleep 0.5; end; set :break_active, false; sleep rrand(8, 16); else; sleep rrand(4, 8); end; else; sleep 8; end; end

live_loop :break_snare do; t = vt; if t > 75 && get(:break_active); break_level = [(t - 75) / 45.0, 1.0].min; if one_in(3); with_fx :reverb, room: 0.4, mix: 0.3 do; with_fx :hpf, cutoff: 60 do; sample :sn_dub, amp: 0.25 + break_level * 0.20, rate: rrand(0.8, 1.2), cutoff: rrand(70, 90), release: rrand(0.1, 0.3), pan: rrand(-0.4, 0.4); end; end; end; sleep 0.25; else; sleep 2; end; end

live_loop :jungle_bass do; t = vt; if t > 90 && get(:break_active); jungle_level = [(t - 90) / 30.0, 1.0].min; with_fx :reverb, room: 0.2, mix: 0.1 do; with_fx :lpf, cutoff: 50 do; use_synth :subpulse; play choose([24, 26, 28, 31]), amp: 0.20 + jungle_level * 0.15, attack: 0.01, sustain: 0.1, release: 0.3, cutoff: rrand(40, 60), pulse_width: rrand(0.3, 0.7), pan: rrand(-0.2, 0.2); end; end; sleep choose([0.25, 0.5, 0.75]); else; sleep 4; end; end
