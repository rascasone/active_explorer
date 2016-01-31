require 'spec_helper'

describe MindMapper do

  it 'should export Person class to PNG' do
    person = Person.new
    person.generate_mindmap

    file_path = "mindmap/person.png"
    expect(File).to exist(file_path), "File #{file_path} doesn't exist."
  end
end