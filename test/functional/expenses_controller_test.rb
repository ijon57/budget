require 'test_helper'

class ExpensesControllerTest < ActionController::TestCase
  def setup
    sign_in users(:user_with_wallet_1)
  end

  def after
    DatabaseCleaner.clean
  end

  private
  def assert_invalid(args)
    assert_equal Expense.new(args).valid?, false
  end

  def assert_valid(args)
    assert_equal Expense.new(args).valid?, true
  end

  public
  test "should get new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:expense)
  end

  test "should be redirected to sign_in" do
    sign_out users(:user_with_wallet_1)
    get :new
    assert_response 302
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:expenses)
  end

  test "should get table with ten rows on first page" do
    get :index, :page => 1
    assert_select 'tbody tr', count: 10
  end

  test "should get table with one row on second page" do
    get :index, :page => 2
    assert_select 'tbody tr', count: 1
  end

  test "should get index with information about no expenses on third page" do
    get :index, :page => 3
    assert_select 'p', 'No expenses'
  end

  test "first tr should have 'warning' class" do
    get :index
    assert_select 'tr.warning'
  end

  test "table should contain information about name, amount, date and also action buttons" do
    get :index
    assert_select 'thead th', 'Name'
    assert_select 'thead th', 'Amount'
    assert_select 'thead th', 'Date'
    assert_select 'thead th', 'Actions'
  end

  test "expense with name 'First' should be on the top of table" do
    get :index
    assert_select 'tbody tr:first-child td:first-child', 'First'
  end

  test "table should contain delete buttons" do
    get :index
    assert_select 'tbody tr td a', 'Delete'
  end

  test "should contain pagination" do
    get :index
    assert_select 'div.pagination'
  end

  test "should contain pagination with two pages" do
    get :index
    assert_select 'div.pagination li', count: 4
  end

  test "should not contain pagination" do
    sign_out users(:user_with_wallet_1)
    sign_in users(:user_with_wallet_2)
    get :index
    assert_select 'div.pagination', count: 0
  end

  test "should get index with pagination" do
    get :index
    assert_select 'div.pagination'
  end

  test "should get index with information about no expenses" do
    sign_in users(:user_without_expenses_1)
    get :index
    assert_select 'p', 'No expenses'
  end

  test "should contain link to adding new expense" do
    get :index
    assert_select 'div.form-actions a', 'Add new expense'
  end

  test "test form is visible on expense page" do
    get :new
    assert_select 'form' do
      assert_select 'input#expense_name'
      assert_select 'input#expense_amount'
      assert_select 'input#expense_execution_date'
      assert_select 'select#expense_wallet_id'
      assert_select 'input[TYPE=submit]'
    end
  end

  test "should redirect to new budget if there are not any wallets in database" do
    sign_in users(:user_without_wallet_1)
    get :new
    assert_redirected_to :new_budget
  end

  test "should create expense and redirect to new with notice on valid inputs" do
    post :create, expense: { name: 'My new SSD', amount: 500, wallet_id: 1, execution_date: '2012-11-25' }
    assert_valid(@request.params[:expense])
    assert_redirected_to :new_expense
    assert_equal 'Expense was successfully created.', flash[:notice]
  end

  test "should render new template on invalids inputs" do
    post :create, expense: { name: 'Milk', amount: -100 }
    assert_invalid(@request.params[:expense])
    assert_template :new
  end

  test "should destroy expense and redirect to all_expense" do
    assert_difference('Expense.count', -1) do
      delete :destroy, id: 1
    end
    assert_equal 'Expense was successfully deleted', flash[:notice]
    assert_redirected_to :all_expenses
  end

  test "should not destroy expense with belongs to another user" do
    assert_no_difference('Expense.count') do
      delete :destroy, id: 12
    end
    assert_equal "Couldn't find expense", flash[:notice]
    assert_redirected_to :all_expenses
  end

  test "should not destroy expense does not exist" do
    assert_no_difference('Expense.count') do
      delete :destroy, id: 100
    end
    assert_equal "Couldn't find expense", flash[:notice]
    assert_redirected_to :all_expenses
  end
end
