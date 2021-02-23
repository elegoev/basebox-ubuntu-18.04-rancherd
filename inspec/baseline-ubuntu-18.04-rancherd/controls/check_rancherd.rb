# copyright: 2020, Urs Voegele

title "check rancherd"

# check rancherd package
control "rancherd-1.0" do                      # A unique ID for this control
  impact 1.0                                   # The criticality, if this control fails.
  title "check if rancherd command exists"     # A human-readable title
  desc "check rancherd command"
  describe command('rancherd --version') do
    its('exit_status') { should eq 0 }
  end
end

# check rancherd service
control "rancherd-2.0" do                     # A unique ID for this control
  impact 1.0                                  # The criticality, if this control fails.
  title "check if rancherd is running"        # A human-readable title
  desc "check rancherd service"
  describe service('rancherd-server') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end
