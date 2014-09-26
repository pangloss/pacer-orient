class Java::ComOrientechnologiesOrientCoreId::ORecordId
  def inspect
    to_s.inspect
  end

  def to_s
    toString[1..-1]
  end
end
