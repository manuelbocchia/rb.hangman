# Game class to handle games. It has a player initializer. 
# The game object:
# - finds the word
# - hides the word
# - checks the letters of the word
# - handles the stick-man.
# I need to work on:
# - handling game state (saving and loading).
# - game looping after one is finishing.
require 'yaml'

#So far, I set up the game, the stickman drawer according to the tries, 
class Game
    attr_reader :word, :player, :turn, :hidden_word
    attr_accessor :tries
    @@incorrect_guesses = []
    @@correct_guesses = []
# The game starts by selecting the words that fit between 5 and 12 characters
    def initialize(player1)
        @player = player1
        IO.sysopen('google-10000-english-no-swears.txt')
        words = IO.new(5)
        @word_arr = []
        words.each do |word|
            @word_arr << word if word.length > 5 && word.length < 12
        end
    end
    #the guess handles the input, and then collects a correct or incorrect input.
    def guess(guess)
        @guess = guess
        if /^[a-z]{1}$/i =~ @guess
                if @word.split("").any?(@guess)
                @@correct_guesses << @guess
                else
                @@incorrect_guesses << @guess
                end
            "You chose #{guess}."
            if @word.split("").any?(@guess)
            hide_word(@guess)
            end
                 
        elsif /save/i =~ @guess
            self.save        
        else puts "Wrong input."
        end
    end
    # new_word selects a random word from the selection
    def new_word
        @word = @word_arr.sample.chomp
        @@incorrect_guesses = []
        @@correct_guesses = []
    end
    #hide_word is in charge of hiding the word with slashes, and to un-hide as the player incorrect_guesses letters.
    def hide_word(guessed = "")
        letters = @word.split("")
        slash_arr = []
        letters.each {|letter| guessed == letter || @@correct_guesses.any?(letter) ? slash_arr << letter : slash_arr << " _ "}
        @hidden_word = slash_arr.join
    end
    #stickman draws the stickman according to the number of incorrect incorrect_guesses.
    def stickman
        case @@incorrect_guesses.length
        when 0
            puts "\n Keep going!"
        when 1
            puts "___\n  |\n  O\n \n "
            puts "\n Keep going!"
        when 2
            puts "___\n  |\n  O\n  | \n "
            puts "\n Keep going!"
        when 3
            puts "___\n  |\n  O\n /| \n "
            puts "\n Keep going!"
        when 4
            puts "___\n  |\n  O\n /|\\ \n "
            puts "\n Careful now!"
        when 5
            puts "___\n  |\n  O\n /|\\ \n /"
            puts "\n Careful now!!"
        when 6
            puts "___\n  |\n  O\n /|\\ \n / \\"  
            puts "\n IT'S OVER."
        end
    end
    # first, save the game

    def save
        @save_file = File.open("save_game.txt", "w")
        @new_save = {word:@word,incorrect:@@incorrect_guesses,correct:@@correct_guesses}
        @save_file.puts(YAML.dump(@new_save))
        puts "\n Game Saved."
        puts "\n Would you like to quit?"
        quit = gets.chomp
            if /y/i =~ quit
                abort("Thanks for playing!")
            end
    end

    # need a load function to restore a saved game
    def load
        @save_file = File.open("save_game.txt", "r")
        @saved_game = YAML.load(@save_file.read)
        @word = @saved_game[:word] 
        @@incorrect_guesses = @saved_game[:incorrect]
        @@correct_guesses = @saved_game[:correct]
        puts "n\ Game Loaded!" 
    end
    # play handles the UI and game loop
    def play
        answer = "yes"
    #the game starts, and the answer is "yes" which I use to continue on the loop. As long as the answer is "yes" I'm playing the game again.

    #I broke the goddamn game loop
        
    while answer =~ /y/i  do

            puts "\n Would you like to load a saved game?"
            load_answer = gets.chomp
                if load_answer =~ /y/i
                    self.load
                    self.hide_word
                    self.stickman
                    puts "\n You've previously played: #{@@incorrect_guesses.join("/")}"
                else
                self.new_word
                self.hide_word
                end
            

            puts "\n Time to play. \n Guess a letter from the hidden word, #{@player}."
            puts @hidden_word
            
            while (@@incorrect_guesses.length != 6 && @hidden_word.length != @word.length) do
                self.guess(gets.chomp)
                puts "\n"
                puts @hidden_word
                unless @hidden_word.length == @word.length || @@incorrect_guesses.length == 0 || @@incorrect_guesses.length == 6 
                    self.stickman
                    puts "\n You've played #{@@incorrect_guesses.join("/")}"
                end
            end
            if @@incorrect_guesses.length == 6
                self.stickman
                puts "\n The word was: * #{@word} * ..."
                puts "Play again?"
                answer = gets.chomp
            end
            if @hidden_word.length == @word.length
                puts "\n The word was: * #{@word} * !!"
                puts "\n You've won! Congrats!"
                puts " Play again?"
                answer = gets.chomp
            end
        end
    end
end       




puts "Welcome to Hangman by Manu"

game1 = Game.new("Manuel")

puts game1.player
game1.play