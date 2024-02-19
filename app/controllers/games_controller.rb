require 'net/http'
require 'uri'
require 'json' # Ensure JSON is required

class GamesController < ApplicationController
  def new
    @list_random_letters = ('a'..'z').to_a.sample(8)
    session[:list_random_letters] = @list_random_letters
  end

  def can_construct_word?(word_proposed, list_random_letters)
    # Create a copy of the list_random_letters array so we can modify it without affecting the original
    available_letters = list_random_letters.dup

    word_proposed.each_char do |char|
      # Check if the character is in available_letters
      if available_letters.include?(char)
        # If found, remove that character from available_letters
        available_letters.delete_at(available_letters.index(char))
      else
        # If not found, return false as the word cannot be constructed
        return false
      end
    end

    # If we get through all characters without returning false, the word can be constructed
    true
  end

  def score
    @list_random_letters = session[:list_random_letters] # Retrieve from session

    @proposed_word = params[:proposed_word]
    url_string = "https://wagon-dictionary.herokuapp.com/#{@proposed_word}"
    url = URI.parse(url_string)
    response = Net::HTTP.get(url)  # Get the response as a string
    @parsed_response = JSON.parse(response)["found"]  # Parse the string into a Ruby hash

    @can_construct_word = can_construct_word?(@proposed_word, @list_random_letters)

    if @can_construct_word === false
      @result_string = "# The word can’t be built out of the original grid ❌"
    elsif @can_construct_word === true && @parsed_response === true
      @result_string = "# The word is valid according to the grid and is an English word ✅"
    else
      @result_string = "# The word is valid according to the grid, but is not a valid English word ❌"
    end
  end
end
