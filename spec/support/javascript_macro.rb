module JavascriptMacro
  def wait_until(seconds = 5, &block)
    timeout(seconds) do
      loop do
        begin
          ret = block.call
          break ret if ret
        rescue Capybara::Poltergeist::JavascriptError
        end
        sleep 0.01
      end
    end
  end

  def confirm_dialog(ret, &block)
    page.execute_script "__backup = window.confirm; window.confirm = function(){return #{ret};}"
    block.call
  ensure
    page.execute_script "window.confirm = __backup;"
  end
end
