#!/usr/bin/env ruby
require 'json'
class JsonToCsv

  def initialize
    @keys = []
    @lines = []
    @currentLine = {}
    @newKey = []

    @csvPath = '~/file.csv'
  end

  def transform(json)
    """
    The function to transform the JSON to CSV 
    """
    #Check if the entry file is a good JSON 
    if validJson? json
      json = JSON.parse(json)
      if json.respond_to?("each")
        json.each do |object|
          #1 Get all keys
          getAllKeys object
        end
        #2 Get all values
        createCSV
      else
        puts "This is not an array" 
      end    
    else
      puts "This is not a valid JSON 2" 
    end
  end

  private
  def validJson?(json)
    """
    The function to check if the json is valid 
    """
    JSON.parse(json)
    return true
  rescue JSON::ParserError => e
    return false
  end

  def isHash?(value)
    return value.respond_to?(:to_hash) # value.class == Hash
  end

  def isArray?(value)
    return value.respond_to?(:each) # value.class == Array
  end

  def formatArray(value)
    return "\"#{value.join(",")}\""
  end

  def formatValue(value)
    if isArray? value
      return formatArray value
    else
      return value
    end
  end

  def addKey(key)
    if !@keys.include? key
      @keys.push(key)
    end
  end

  def getAllKeys object
    """
    Get all keys to use and format if needed + save object with the new keys
    """
    @currentLine = {}
    object.each do |key,value|
      recursiveGetValue(key, value)
    end
    @lines.push(@currentLine)
  end

  def recursiveGetValue(key, value)
    @newKey.push key
    if isHash? value
      value.each do |key2, value2|
        recursiveGetValue(key2,value2)
      end
      @newKey.pop
    else
      theKey = @newKey.join(".")
      addKey(theKey)
      @currentLine[theKey] = formatValue(value)
      @newKey.pop
    end
  end

  def createCSV
    #puts @keys.join(",")
    #@lines.each do |line|
    #  theLine = createLine line
    #  puts theLine.join(",")
    #end
    
    require "csv"
    CSV.open(@csvPath, "wb") do |csv|
      csv << @keys
      @lines.each do |line|
        theLine = createLine line
        csv << theLine
      end
    end

  end

  def createLine line
    """
    create temporary object and add parametre if does not exist in the class
    """
    newLine = []
    @keys.each do |key|
      value = line[key]
      if !value
        newLine.push ''
      else
        newLine.push value
      end
    end
    return newLine
  end

end


if __FILE__ == $0
  src = '~/users.json'; #TODO change for the absolute path
  file = File.read(src)
  jtc = JsonToCsv.new 
  jtc.transform(file)

end