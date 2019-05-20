control 'operating_system' do

  describe command('lsb_release -a') do
    ver = ENV['OS_VER']
    its('stdout') { should match (/#{ver}test/) }
  end

end
