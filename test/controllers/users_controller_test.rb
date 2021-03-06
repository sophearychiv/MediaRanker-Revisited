require "test_helper"

describe UsersController do
  describe "index" do
    it "requires the user to log in" do
      get users_path
      expect(flash[:status]).must_equal :error
      expect(flash[:result_text]).must_equal "You must be logged in to perform this action."
      must_respond_with :redirect
      must_redirect_to root_path
    end
    it "can get index page" do
      perform_login
      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "requires the user to log in" do
      user = users(:sophie)
      get user_path(user.id)
      expect(flash[:status]).must_equal :error
      expect(flash[:result_text]).must_equal "You must be logged in to perform this action."
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "can get the show page" do
      user = users(:sophie)
      perform_login(user)
      get user_path(user.id)
      must_respond_with :success
    end
  end
  describe "create" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count
      user = users(:sophie)
      perform_login(user)
      must_redirect_to root_path

      session[:user_id].must_equal user.id
      User.count.must_equal start_count
      expect(flash[:success]).must_equal "Logged in as returning user #{user.name}"
    end

    it "creats an account for a new user and redirects to the root path" do
      user = User.new(provider: "github", uid: 999, username: "test_user", name: "sam", email: "test@ada.com")
      expect {
        perform_login(user)
      }.must_change "User.count", 1

      must_redirect_to root_path
      user = User.find_by(uid: user.uid, provider: user.provider)

      expect(session[:user_id]).must_equal user.id
      expect(flash[:success]).must_equal "Logged in as new user #{user.name}"
    end

    it "redirects to the login route and give flash notice if given invalid user data" do
      invalid_user = User.new(username: nil)
      expect(invalid_user).wont_be :valid?

      expect {
        perform_login(invalid_user)
      }.wont_change "User.count"
      must_redirect_to root_path

      expect(session[:user_id]).must_equal nil
      expect(flash[:error]).must_equal "Could not create new user account: #{invalid_user.errors.messages}"
    end
  end

  describe "destroy" do
    it "logs a user out" do
      perform_login
      expect {
        delete logout_path
      }.wont_change "User.count"
      expect(session[:user_id]).must_be_nil
      expect(flash[:result_text]).must_equal "Successfully logged out!"
      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end
