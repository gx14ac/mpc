use_bpm 117

# ===== Main Kick Pattern (More Groovy) =====
live_loop :aphex_kick do
  # よりまとまったキックパターン（4つ打ちベース）
  kick_pattern = [1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0]
  
  kick_pattern.each_with_index do |hit, i|
    if hit == 1
      # 1拍目と3拍目は強く、他は少し弱く
      base_amp = (i % 8 == 0) ? 0.9 : 0.7
      # 時々ピッチを変える（控えめに）
      rate_var = one_in(8) ? rrand(0.95, 1.05) : 1.0
      
      sample :bd_tek,
        amp: base_amp + rrand(-0.1, 0.1),
        rate: rate_var,
        cutoff: rrand(80, 95),
        pan: rrand(-0.05, 0.05)
    end
    sleep 0.25
  end
end

# ===== Solid Snare =====
live_loop :aphex_snare do
  # より安定したスネアパターン
  snare_pattern = [0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0]
  
  snare_pattern.each_with_index do |hit, i|
    if hit == 1
      # 基本は普通のスネア、時々グリッチ
      if one_in(6)  # 頻度を下げる
        with_fx :reverb, room: 0.2, mix: 0.3 do
          sample :sn_dub,
            amp: rrand(0.6, 0.8),
            rate: rrand(0.9, 1.2),
            cutoff: rrand(90, 110),
            pan: rrand(-0.2, 0.2)
        end
      else
        sample :sn_dub,
          amp: rrand(0.7, 0.9),
          rate: rrand(0.95, 1.05),
          cutoff: rrand(95, 105),
          pan: rrand(-0.1, 0.1)
      end
    end
    sleep 0.25
  end
end

# ===== Steady Hi-Hats =====
live_loop :aphex_hats do
  # より規則的なハイハット（8分音符ベース）
  hat_pattern = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0]
  
  hat_pattern.each_with_index do |hit, i|
    if hit == 1
      # オフビートを少し強調
      base_amp = (i % 4 == 2) ? 0.4 : 0.3
      
      # 時々違うサンプル
      if one_in(8)
        sample :drum_cymbal_pedal,
          amp: base_amp + rrand(-0.05, 0.1),
          rate: rrand(1.0, 1.2),
          cutoff: rrand(100, 120),
          finish: 0.3,
          pan: rrand(-0.3, 0.3)
      else
        sample :drum_cymbal_closed,
          amp: base_amp + rrand(-0.05, 0.05),
          rate: rrand(0.98, 1.02),
          cutoff: rrand(110, 130),
          finish: 0.2,
          pan: rrand(-0.2, 0.2)
      end
    end
    sleep 0.125  # 16分音符
  end
end

# ===== Groove Enhancer =====
live_loop :groove_perc do
  # グルーヴを強化するパーカッション
  sleep 1
  
  if one_in(4)
    sample :perc_snap,
      amp: 0.3,
      rate: rrand(0.9, 1.1),
      pan: rrand(-0.4, 0.4)
  end
  
  sleep 1
  
  if one_in(6)
    sample :drum_tom_lo_soft,
      amp: 0.4,
      rate: rrand(0.8, 1.0),
      cutoff: 90,
      pan: rrand(-0.3, 0.3)
  end
  
  sleep 2
end

# ===== Acid Bass Line =====
live_loop :aphex_bass do
  use_synth :tb303
  
  # 酸っぱいベースライン
  notes = [:c2, :c2, :g2, :f2, :c2, :bb1, :c2, :eb2]
  
  notes.each_with_index do |note, i|
    play note,
      amp: rrand(0.4, 0.7),
      cutoff: rrand(60, 100),
      res: rrand(0.7, 0.9),
      attack: 0.01,
      release: rrand(0.2, 0.8),
      pan: rrand(-0.2, 0.2)
    
    sleep [0.5, 0.25, 0.75].choose
  end
end

# ===== Glitch Percussion =====
live_loop :glitch_perc do
  # ランダムなグリッチパーカッション
  sleep rrand(0.5, 2)
  
  if one_in(3)
    perc_samples = [:perc_snap, :perc_snap2, :drum_tom_lo_soft, :drum_tom_hi_soft]
    
    with_fx :bitcrusher, bits: rrand(4, 8), sample_rate: rrand(8000, 20000) do
      with_fx :pan, pan: rrand(-0.8, 0.8) do
        sample perc_samples.choose,
          amp: rrand(0.3, 0.6),
          rate: rrand(0.5, 2.0),
          start: rrand(0, 0.5),
          finish: rrand(0.5, 1)
      end
    end
  end
end

# ===== Ambient Pads =====
live_loop :aphex_pads do
  use_synth :hollow
  
  # 不協和音的なパッド
  chord_notes = [:c3, :eb3, :gb3, :a3]
  
  with_fx :reverb, room: 0.8, mix: 0.6 do
    with_fx :lpf, cutoff: rrand(70, 90), res: 0.3 do
      play_chord chord_notes,
        amp: rrand(0.2, 0.4),
        attack: rrand(2, 4),
        sustain: rrand(4, 8),
        release: rrand(6, 12),
        cutoff: rrand(60, 80),
        pan: rrand(-0.3, 0.3)
    end
  end
  
  sleep rrand(8, 16)
end

# ===== Weird Melody =====
live_loop :weird_melody do
  use_synth :prophet
  
  # 奇妙で予測不可能なメロディー
  scale_notes = scale(:c4, :minor_pentatonic) + scale(:c4, :chromatic).take(5)
  
  if one_in(4)
    with_fx :echo, phase: 0.375, decay: 3, mix: 0.4 do
      with_fx :pitch_shift, pitch: rrand(-0.5, 0.5), mix: 0.3 do
        note = scale_notes.choose
        play note,
          amp: rrand(0.3, 0.5),
          attack: rrand(0.01, 0.3),
          release: rrand(0.2, 1.5),
          cutoff: rrand(80, 120),
          res: rrand(0.1, 0.5),
          pan: rrand(-0.7, 0.7)
      end
    end
  end
  
  sleep [0.25, 0.5, 0.75, 1, 1.5].choose
end

# ===== Kamide Vocal Chops =====
live_loop :kamide_chops do
  # ランダムな間隔で掛け声
  sleep rrand(4, 12)
  
  if one_in(2)
    # グリッチ効果付きボーカル
    with_fx :bitcrusher, bits: rrand(6, 12), sample_rate: rrand(12000, 44100) do
      with_fx :echo, phase: [0.125, 0.25, 0.375].choose, decay: 2, mix: 0.4 do
        with_fx :pitch_shift, pitch: rrand(-0.3, 0.3), mix: 0.6 do
          sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/kamide-kumada.mp3",
            amp: rrand(0.4, 0.7),
            rate: rrand(0.8, 1.3),
            start: rrand(0, 0.3),
            finish: rrand(0.7, 1),
            cutoff: rrand(80, 120),
            pan: rrand(-0.6, 0.6)
        end
      end
    end
  end
end

# ===== Vocal Stabs =====
live_loop :vocal_stabs do
  # リズムに合わせた短いボーカルスタブ
  sleep rrand(2, 8)
  
  if one_in(3)
    # 短くチョップされたボーカル
    4.times do
      with_fx :hpf, cutoff: rrand(60, 120) do
        sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/kamide-kumada.mp3",
          amp: rrand(0.3, 0.5),
          rate: rrand(1.2, 2.0),
          start: rrand(0, 0.8),
          finish: rrand(0.1, 0.4),
          attack: 0.01,
          release: 0.1,
          pan: rrand(-0.8, 0.8)
      end
      sleep [0.125, 0.25].choose
    end
  end
end

# ===== Reverse Vocal =====
live_loop :reverse_vocal do
  # 時々リバースボーカル
  sleep rrand(8, 20)
  
  if one_in(4)
    with_fx :reverb, room: 0.6, mix: 0.5 do
      with_fx :lpf, cutoff: rrand(60, 100) do
        sample "/Users/shinta/git/github.com/gx14ac/mpc/assets/kamide-kumada.mp3",
          amp: rrand(0.5, 0.8),
          rate: rrand(-1.5, -0.8),  # リバース再生
          start: rrand(0.2, 0.8),
          finish: rrand(0, 0.6),
          attack: 0.5,
          release: 2,
          pan: rrand(-0.4, 0.4)
      end
    end
  end
end

# ===== Breakbeat Elements =====
live_loop :breakbeat do
  # 時々ブレイクビート要素
  if one_in(8)
    4.times do
      sample :loop_amen,
        amp: 0.6,
        rate: rrand(0.8, 1.2),
        start: rrand(0, 0.7),
        finish: rrand(0.3, 1),
        cutoff: rrand(70, 110),
        pan: rrand(-0.4, 0.4)
      sleep 0.125
    end
  else
    sleep 2
  end
end
