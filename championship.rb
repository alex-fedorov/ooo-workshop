class Championship
  Greater = 1
  Equal = 0
  Less = -1

  def self.max(candidates)
    candidates.inject { |champion, x| champion.max(champion, x) }
  end

  def self.sort(chances)
    chances.sort { |a, b| a.compare(b) }
  end
end
