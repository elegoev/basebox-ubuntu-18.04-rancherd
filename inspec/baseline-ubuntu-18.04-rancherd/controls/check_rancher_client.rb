# copyright: 2021, Urs Voegele

title "check rancher client"

# check rke command
control "ranchercli-1.0" do                    # A unique ID for this control
  impact 1.0                                   # The criticality, if this control fails.
  title "check if rancher command exists"      # A human-readable title
  desc "check rancher command"
  describe command('rancher --version') do
    its('exit_status') { should eq 0 }
  end
end
