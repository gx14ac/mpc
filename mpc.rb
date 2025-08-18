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
  sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/roma-master-voice.mp3", amp: 0.05
end

# ===== Zakuzaku =====
zak="/Users/shinta/git/github.com/gx14ac/mpc/assets/walk-zakuzaku.mp3"
with_fx :level, amp:0 do |fx_z|
  sync :ririku_done
  
  live_loop :z_player do
    with_fx :hpf, cutoff: 20 do
      with_fx :lpf, cutoff: 90 do
        with_fx :reverb, room: 0.3, mix: 0.15 do
          loop_xfade zak, amp: 0.09, st: 0.01, fn: 0.99, xf: 0.25, pan: rrand(-0.6, 0.6)
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
      amp: rrand(0.03, 0.08),  # 音量もランダム
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

##| # ===== Piano =====
##| piano_wait=100; piano_fade=10; piano_lvl=0.8
##| with_fx :level, amp:0 do |fx_p|
##|   in_thread do
##|     sleep sec(piano_wait); fade_to fx_p, piano_lvl, piano_fade, 12, :piano_amp
##|   end
##|   live_loop :piano do
##|     use_synth :piano
##|     play_chord [:a3,:c4,:e4,:g4], amp:0.15; sleep 2
##|     play_chord [:d3,:f3,:a3,:c4], amp:0.15; sleep 2
##|     play_chord [:g3,:b3,:d4,:f4], amp:0.15; sleep 2
##|     play_chord [:c3,:e3,:g3,:b3], amp:0.15; sleep 2
##|   end
##| end