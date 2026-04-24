# 試合終了時の表示（index.html drawResult と同一）
module Rubyfight
  module Match
    def self.result_headline(p1_score, p2_score, vs_cpu)
      if p1_score > p2_score
        'P1 WINS!'
      elsif p2_score > p1_score
        vs_cpu ? 'CPU WINS!' : 'P2 WINS!'
      else
        'DRAW!'
      end
    end

    # 描画色の切り替え用（'p1' / 'p2' / 'tie'）
    def self.result_tone(p1_score, p2_score)
      if p1_score > p2_score
        'p1'
      elsif p2_score > p1_score
        'p2'
      else
        'tie'
      end
    end
  end
end
