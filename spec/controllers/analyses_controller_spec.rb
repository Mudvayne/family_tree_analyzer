require 'spec_helper'

describe AnalysesController do

  describe "GET 'analysis'" do
    it "returns http success" do
      get 'analysis'
      response.should be_success
    end
  end

end
