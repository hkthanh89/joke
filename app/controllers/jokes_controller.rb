class JokesController < ApplicationController

  def index
    session[:read_joke_ids] ||= []
    if session[:read_joke_ids].empty?
      @joke = Joke.first
    else
      @joke = Joke.find_unread_jokes(session[:read_joke_ids]).first
    end
  end

  def like
    session[:read_joke_ids] << params[:id]
    joke = Joke.find(params[:id])
    joke.like = joke.like.to_i + 1
    joke.save
    @joke = Joke.find_unread_jokes(session[:read_joke_ids]).first
  end

  def dislike
    session[:read_joke_ids] << params[:id]
    joke = Joke.find(params[:id])
    joke.dislike = joke.dislike.to_i - 1
    joke.save
    @joke = Joke.find_unread_jokes(session[:read_joke_ids]).first
    respond_to do |format|
      format.js
    end
  end
end
