require File.join(File.dirname(__FILE__), 'spec_helper')

describe RSpec::Benchmark::Math do
  describe '#fit_exponential' do
    it 'should match a clean dataset' do
      x = [1.0, 2.0, 3.0, 4.0, 5.0]
      y = x.map { |n| 1.1 * Math.exp(2.1 * n) }

      assert_fit :exponential, x, y, 1.0, 1.1, 2.1
    end
    
    it 'should match a noisy dataset' do
      x = [1.0, 1.9, 2.6, 3.4, 5.0]
      y = [12, 10, 8.2, 6.9, 5.9]

      # verified with Numbers and R
      assert_fit :exponential, x, y, 0.95, 13.81148, -0.1820
    end
  end
  
  describe '#fit_linear' do
    it 'should match a clean dataset' do
      # y = m * x + b where m = 2.2, b = 3.1
      x = (1..5).to_a
      y = x.map { |n| 2.2 * n + 3.1 }

      assert_fit :linear, x, y, 1.0, 3.1, 2.2
    end
    
    it 'should match a noisy dataset' do
      x = [ 60,  61,  62,  63,  65]
      y = [3.1, 3.6, 3.8, 4.0, 4.1]

      # verified in numbers and R
      assert_fit :linear, x, y, 0.8315, -7.9635, 0.1878
    end
  end
  
  describe '#fit_power' do
    it 'should match a clean dataset' do
      # y = A x ** B, where B = b and A = e ** a
      # if, A = 1, B = 2, then

      x = [1.0, 2.0, 3.0, 4.0, 5.0]
      y = [1.0, 4.0, 9.0, 16.0, 25.0]

      assert_fit :power, x, y, 1.0, 1.0, 2.0
    end
    
    it 'should match a slightly noisy dataset' do
      # from www.engr.uidaho.edu/thompson/courses/ME330/lecture/least_squares.html
      x = [10, 12, 15, 17, 20, 22, 25, 27, 30, 32, 35]
      y = [95, 105, 125, 141, 173, 200, 253, 298, 385, 459, 602]

      # verified in numbers
      assert_fit :power, x, y, 0.90, 2.6217, 1.4556
    end
    
    it 'should match a noisier dataset' do
      # income to % of households below income amount
      # http://library.wolfram.com/infocenter/Conferences/6461/PowerLaws.nb
      x = [15000, 25000, 35000, 50000, 75000, 100000]
      y = [0.154, 0.283, 0.402, 0.55, 0.733, 0.843]

      # verified in numbers
      assert_fit :power, x, y, 0.96, 3.119e-5, 0.8959
    end
  end

  # Helper assertion copied from minitest's tests.
  def assert_fit msg, x, y, fit, exp_a, exp_b
    a, b, rr = RSpec::Benchmark::Math.send "fit_#{msg}", x, y

    rr.should be >= fit
    exp_a.should be_within(0.001).of(a)
    exp_b.should be_within(0.001).of(b)
  end
end