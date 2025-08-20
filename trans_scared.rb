# ===== TRANS SCARED - 恐怖テクノ（短縮版） =====
use_bpm 110
define :sec do |s|; s * (60.0 / current_bpm); end

# ===== 心臓音 =====
live_loop :heartbeat do
  # 正常なリズム（80%の確率）vs 早いリズム（20%の確率）
  if one_in(5)
    # たまに早くなる（緊張・興奮時）
    beat_interval = choose([0.6, 0.7, 0.8, 0.65, 0.75])
    amp_multiplier = 1.2
  else
    # 正常なリズム
    beat_interval = choose([1.0, 1.1, 0.95, 1.05, 1.15])
    amp_multiplier = 1.0
  end
  
  with_fx :reverb, room: 0.5, mix: 0.3 do; with_fx :lpf, cutoff: rrand(55, 70) do
      # 第一音（lub）
      sample :bd_gas, amp: rrand(0.65, 1.00) * amp_multiplier, rate: rrand(0.6, 0.8), cutoff: rrand(50, 65), release: 0.3, pan: rrand(-0.2, 0.2)
      sleep 0.15
      # 第二音（dub）
      sample :bd_soft, amp: rrand(0.45, 0.70) * amp_multiplier, rate: rrand(0.7, 0.9), cutoff: rrand(60, 75), release: 0.2, pan: rrand(-0.1, 0.1)
  end; end
  sleep beat_interval
end

# ===== 自然の恐怖音（風・森の奥） =====
live_loop :nature_horror do; t = vt; if t > 20; nature_level = [t / 120.0, 1.0].min; if one_in(12); with_fx :reverb, room: 0.95, mix: 0.9, damp: 0.8 do; with_fx :echo, phase: rrand(4.0, 8.0), decay: rrand(15, 25), mix: 0.6 do; with_fx :pitch_shift, pitch: rrand(-0.5, -0.2), mix: 0.7 do; with_fx :lpf, cutoff: rrand(25, 45) do; use_synth :noise; play choose([:c1, :d1, :e1]), amp: 0.08 + nature_level * 0.15, attack: rrand(8, 15), sustain: rrand(20, 35), release: rrand(12, 25), cutoff: rrand(20, 40), pan: rrand(-0.9, 0.9); end; end; end; end; sleep rrand(25, 45); else; sleep rrand(15, 30); end; else; sleep 20; end; end

# ===== 深い森の呼び声 =====
live_loop :forest_whisper do; t = vt; if t > 80; whisper_level = [(t - 80) / 80.0, 1.0].min; if one_in(20); with_fx :reverb, room: 0.9, mix: 0.85, damp: 0.7 do; with_fx :echo, phase: rrand(6.0, 12.0), decay: rrand(20, 30), mix: 0.5 do; with_fx :pitch_shift, pitch: rrand(-0.8, -0.4), mix: 0.8 do; with_fx :lpf, cutoff: rrand(30, 50) do; use_synth :hollow; play choose([20, 22, 24]), amp: 0.05 + whisper_level * 0.12, attack: rrand(10, 20), sustain: rrand(15, 30), release: rrand(15, 25), cutoff: rrand(25, 45), pan: rrand(-0.8, 0.8); end; end; end; end; sleep rrand(30, 60); else; sleep rrand(20, 40); end; else; sleep 25; end; end

# ===== 新しいテクノビート =====
live_loop :dark_kick do; t = vt; if t > 30 && one_in(8); intensity = [(t - 30) / 60.0, 1.5].min; with_fx :reverb, room: 0.4, mix: 0.3 do; with_fx :lpf, cutoff: 70 do; sample :bd_boom, amp: 0.6 + rrand(-0.1, 0.1), rate: rrand(0.65, 0.75), cutoff: rrand(55, 65), attack: 0.01, release: rrand(0.6, 1.0); end; end; if one_in(3); sleep rrand(1, 3); sample :bd_808, amp: 0.35 + intensity * 0.25, rate: rrand(0.55, 0.65), cutoff: rrand(50, 60); end; sleep rrand(15, 30); else; sleep rrand(8, 15); end; end

live_loop :minimal_clap do; t = vt; if t > 60; intensity = [(t - 60) / 30.0, 1.0].min; sleep 4; with_fx :reverb, room: 0.6, mix: 0.4 do; with_fx :lpf, cutoff: 95 do; sample :perc_snap, amp: 0.63 + intensity * 0.72, rate: rrand(0.9, 1.1), cutoff: rrand(80, 100), release: 0.4, pan: rrand(-0.2, 0.2); end; end; if one_in(8); sleep 0.25; sample :perc_snap2, amp: 0.35 + intensity * 0.35, rate: 1.2, cutoff: 70, release: 0.2; sleep 3.75; else; sleep 4; end; else; sleep 8; end; end

# live_loop :dark_bass do; t = vt; if t > 45; level = [(t - 45) / 90.0, 1.0].min; with_fx :reverb, room: 0.5, mix: 0.3 do; with_fx :lpf, cutoff: 60 + level * 20 do; use_synth :fm; play choose([28, 30, 26, 29]), amp: 0.41 + level * 0.57, attack: 0.5 + level * 0.3, sustain: 2 + level, release: 3 + level * 2, cutoff: 50 + level * 15, divisor: 2.5, depth: 0.3 + level * 0.2, pan: rrand(-0.2, 0.2); end; end; sleep 4.8 + rrand(-0.5, 0.5); else; sleep 5; end; end
live_loop :atmosphere do; t = vt; if t > 90; atmos = [(t - 90) / 60.0, 1.0].min; if one_in(10); with_fx :reverb, room: 0.8, mix: 0.6 do; with_fx :lpf, cutoff: rrand(40, 60) do; use_synth :dark_ambience; play choose([24, 26, 28]), amp: 0.12 + atmos * 0.18, attack: rrand(5, 10), sustain: rrand(10, 20), release: rrand(8, 15), cutoff: rrand(35, 55), pan: rrand(-0.8, 0.8); end; end; end; end; sleep rrand(8, 15); end

##| # ===== ブレイクビーツ =====
live_loop :breakbeat do; t = vt; if t > 60; break_intensity = [(t - 60) / 60.0, 1.0].min; if one_in(12); set :break_active, true; 4.times do; with_fx :reverb, room: 0.3, mix: 0.2 do; with_fx :lpf, cutoff: 90 do; sample :loop_amen, amp: 0.53 + break_intensity * 0.38, rate: choose([1.0, 1.1, 0.9]), beat_stretch: 2, slice: rrand(0, 7), num_slices: 8, cutoff: rrand(80, 100), pan: rrand(-0.3, 0.3); end; end; sleep 0.5; end; set :break_active, false; sleep rrand(8, 16); else; sleep rrand(4, 8); end; else; sleep 8; end; end

live_loop :break_snare do; t = vt; if t > 75 && get(:break_active); break_level = [(t - 75) / 45.0, 1.0].min; if one_in(3); with_fx :reverb, room: 0.4, mix: 0.3 do; with_fx :hpf, cutoff: 60 do; sample :sn_dub, amp: 0.38 + break_level * 0.30, rate: rrand(0.8, 1.2), cutoff: rrand(70, 90), release: rrand(0.1, 0.3), pan: rrand(-0.4, 0.4); end; end; end; sleep 0.25; else; sleep 2; end; end

live_loop :jungle_bass do; t = vt; if t > 90 && get(:break_active); jungle_level = [(t - 90) / 30.0, 1.0].min; with_fx :reverb, room: 0.2, mix: 0.1 do; with_fx :lpf, cutoff: 50 do; use_synth :subpulse; play choose([24, 26, 28, 31]), amp: 0.30 + jungle_level * 0.23, attack: 0.01, sustain: 0.1, release: 0.3, cutoff: rrand(40, 60), pulse_width: rrand(0.3, 0.7), pan: rrand(-0.2, 0.2); end; end; sleep choose([0.25, 0.5, 0.75]); else; sleep 4; end; end

# ===== カランコロン =====
live_loop :karankoron do; t = vt; if t > 100; level = [(t - 100) / 60.0, 1.0].min; if one_in(18); with_fx :reverb, room: 0.9, mix: 0.8, damp: 0.6 do; with_fx :echo, phase: rrand(3.0, 6.0), decay: rrand(12, 20), mix: 0.4 do; with_fx :lpf, cutoff: rrand(60, 80) do; sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/karankoron.mp3", amp: 0.15 + level * 0.20, rate: rrand(0.8, 1.1), attack: rrand(1.0, 2.5), release: rrand(3.0, 6.0), pan: rrand(-0.7, 0.7); end; end; end; sleep rrand(12, 25); else; sleep rrand(8, 15); end; else; sleep 12; end; end

# ===== 深淵への誘い =====
live_loop :deep_pull do; t = vt; if t > 40; pull_level = [(t - 40) / 120.0, 1.0].min; if one_in(15); with_fx :reverb, room: 0.95, mix: 0.9, damp: 0.9 do; with_fx :echo, phase: rrand(8.0, 16.0), decay: rrand(25, 40), mix: 0.7 do; with_fx :pitch_shift, pitch: rrand(-1.2, -0.3), mix: 0.8 do; with_fx :lpf, cutoff: rrand(30, 50) do; use_synth :hollow; play choose([20, 22, 24, 19]), amp: 0.04 + pull_level * 0.08, attack: rrand(15, 25), sustain: rrand(30, 50), release: rrand(20, 35), cutoff: rrand(25, 40), pan: rrand(-0.9, 0.9); end; end; end; end; sleep rrand(45, 80); else; sleep rrand(25, 50); end; else; sleep 30; end; end

# ===== ランダム音声（エフェクト付き） =====
live_loop :random_voice do; t = vt; if t > 100; voice_level = [(t - 100) / 60.0, 1.0].min; if one_in(15); with_fx :reverb, room: 0.8, mix: 0.7, damp: 0.3 do; with_fx :echo, phase: rrand(2.0, 4.0), decay: rrand(8, 15), mix: 0.5 do; with_fx :pitch_shift, pitch: rrand(-0.3, -0.1), mix: 0.6 do; with_fx :lpf, cutoff: rrand(70, 90) do; with_fx :hpf, cutoff: rrand(30, 50) do; sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/roba-master-yeah-hosse.mp3", amp: 0.23 + voice_level * 0.30, rate: rrand(0.7, 0.9), attack: rrand(0.5, 1.5), release: rrand(2.0, 4.0), pan: rrand(-0.6, 0.6); end; end; end; end; end; sleep rrand(8, 20); else; sleep rrand(6, 12); end; else; sleep 10; end; end
