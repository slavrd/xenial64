control 'operating_system' do

  describe command('lsb_release -a') do
    ver = ENV['TEST_OS_VER']
    its('stdout') { should match (/Ubuntu #{ver}/) }
  end

end
