require File.join(File.dirname(__FILE__), "helper")

with_steps_for :additional_basic, :basic, :global do
  run_story(File.expand_path(__FILE__))
end