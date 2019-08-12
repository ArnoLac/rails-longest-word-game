require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @grid = generate_grid(10)
    @start_time = Time.now.to_i
  end

  def score
    @word = params[:user_input]
    @grid = params[:grid].split(" ")
    @start_time = params[:start_time].to_i
    @end_time = Time.now.to_i
    @result = run_game(@word, @grid, @start_time, @end_time)
  end

  private

  def generate_grid(grid_size)
    alphabet = ("A".."Z").to_a
    grid = []
    (1..grid_size).each { grid << alphabet.sample(1)[0] }
    return grid
  end

  def json_analysis(url)
    word_serialized = open(url).read
    return JSON.parse(word_serialized)
  end

  def run_game(attempt, grid, start_time, end_time)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    if json_analysis(url)["found"]
      if attempt.upcase.split(//).all? { |x| grid.delete_at(grid.index(x)) if grid.include?(x) }
        { message: "well done", score: attempt.length * 20 - (end_time - start_time), time: end_time - start_time }
      else
        { message: "not in the grid", score: 0, time: Time.now - start_time }
      end
    else
      return { message: "not an english word", score: 0, time: Time.now - start_time }
    end
  end

end
