use_bpm 72
x = 72
z = 0.5
i = 0
j = 0

live_loop :piano do
  # 美しいメロディーベースのピアノ
  with_fx :reverb, room: 0.5, mix: 0.4 do
    with_fx :lpf, cutoff: 95 do
      use_synth :piano
      x = 72  # ベース音程
      z = 0.4  # 音量（少し控えめに）
      i = get(:piano_counter) || 0
      
      play x + 2, pan: 0.8, amp: z  # 頭1
      sleep 2
      play x + 6, pan: 0.8, amp: z
      sleep 0.75
      play x + 9, pan: 0.8, amp: z
      sleep 0.5
      play x + 7, pan: 0.8, amp: z
      sleep 0.25
      play x + 6, pan: 0.8, amp: z
      sleep 0.5
      
      play x + 2, pan: 0.8, amp: z  # 頭2
      sleep 2
      play x - 3, pan: 0.8, amp: z
      sleep 0.75
      play x + 2, pan: 0.8, amp: z
      sleep 0.5
      play x + 1, pan: 0.8, amp: z
      sleep 0.75
      
      play x + 2, pan: 0.8, amp: z  # 頭3
      sleep 2
      play x + 14, pan: 0.8, amp: z
      sleep 0.5
      play x + 9, pan: 0.8, amp: z
      sleep 0.5
      play x + 7, pan: 0.8, amp: z
      sleep 0.25
      play x + 6, pan: 0.8, amp: z
      sleep 0.75
      
      play x + 2, pan: 0.8, amp: z  # 頭4
      sleep 2
      play x + 2, pan: 0.8, amp: z
      sleep 0.5
      play x - 3, pan: 0.8, amp: z
      sleep 0.75
      
      if i == 3
        play x + 4, pan: 0.8, amp: z + 0.2, release: 8
        sleep 2.75
        play x + 16, pan: 0.8, amp: z + 0.2, release: 6
        sleep 6
        set :piano_counter, 0  # カウンターリセット
      else
        play x + 4, pan: 0.8, amp: z
        sleep 0.75
        set :piano_counter, i + 1  # カウンター増加
      end
    end
  end
end