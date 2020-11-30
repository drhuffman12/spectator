require "../src/spectator"

macro it_fails(description = nil, &block)
  it {{description}} do
    expect do
      {{block.body}}
    end.to raise_error(Spectator::ExampleFailed)
  end
end

macro specify_fails(description = nil, &block)
  it_fails {{description}} {{block}}
end

module StringHelpers
  # This is a helper method.
  def random_string(length)
    chars = ('a'..'z').to_a
    String.build(length) do |builder|
      length.times { builder << chars.sample }
    end
  end

  # length is now pulled from value defined by `let`.
  def random_string
    chars = ('a'..'z').to_a
    String.build(length) do |builder|
      length.times { builder << chars.sample }
    end
  end
end
