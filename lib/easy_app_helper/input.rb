module EasyAppHelper

  module Input

    DEFAULT_CONFIRMATION_CHOICES = {
        true => %w(Yes y),
        false => %w(No n)
    }

    def get_user_confirmation(choices: DEFAULT_CONFIRMATION_CHOICES,
                              default_choice: 'No',
                              prompt: 'Are you sure ?',
                              strict: false)

      raise 'Invalid choices !' unless choices.is_a? Hash
      values = choices.values.flatten
      raise "Invalid default choice '#{default_choice}' !" unless values.include? default_choice
      return true if EasyAppHelper.config[:auto]
      full_prompt = '%s (%s): ' % [prompt, choices_string(values, default_choice)]
      STDOUT.print full_prompt
      STDOUT.flush
      input = nil
      until values.include? input
        input = STDIN.gets.chomp
        input = default_choice if input.nil? || input.empty?
        unless strict
          input = default_choice unless values.include? input
        end
      end
      choices.each_pair do |res, possible_choices|
        return res if possible_choices.include? input
      end
      raise 'Something wrong happened !'
    end


    def get_user_input(prompt, default=nil)
      full_prompt = (default.nil? or default.empty?) ? "#{prompt}: " : "#{prompt} (default: #{default}): "
      STDOUT.print full_prompt
      STDOUT.flush
      STDIN.gets.chomp
    end

    private


    def choices_string(choices, default_choice, highlight= %w([ ]))
      choices
          .map { |choice| choice == default_choice ? "#{highlight.first}#{choice}#{highlight.last}" : choice }
          .join '/'
    end


  end

end