# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'home page' do
  it 'loads with the correct text' do
    visit '/'
    page.should have_content('HUMAN RIGHTS WEB ARCHIVE')
  end

  it 'checks the default top bar search checkbox' do
    visit '/'
    page.has_checked_field?('#fsfsearch')
  end
end

describe 'about page' do
  it 'loads with the correct text' do
    visit '/about'
    page.should have_content('About the Project')
  end
end

describe 'collection browse page' do
  it 'loads with the correct text' do
    visit '/browse'
    page.should have_content('Collection Browse')
  end
end
