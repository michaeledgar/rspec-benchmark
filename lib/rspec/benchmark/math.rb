module RSpec
  module Benchmark
    module Math
      extend self

      ##
      # Takes an array of x/y pairs and calculates the general R^2 value.
      #
      # See: http://en.wikipedia.org/wiki/Coefficient_of_determination
      
      def fit_error xys
        y_bar  = sigma(xys) { |x, y| y } / xys.size.to_f
        ss_tot = sigma(xys) { |x, y| (y    - y_bar) ** 2 }
        ss_err = sigma(xys) { |x, y| (yield(x) - y) ** 2 }
      
        1 - (ss_err / ss_tot)
      end
      
      ##
      # To fit a functional form: y = ae^(bx).
      #
      # Takes x and y values and returns [a, b, r^2].
      #
      # See: http://mathworld.wolfram.com/LeastSquaresFittingExponential.html
      
      def fit_exponential xs, ys
        n     = xs.size
        xys   = xs.zip(ys)
        sxlny = sigma(xys) { |x,y| x * ::Math.log(y) }
        slny  = sigma(xys) { |x,y| ::Math.log(y)     }
        sx2   = sigma(xys) { |x,y| x * x           }
        sx    = sigma xs
      
        c = n * sx2 - sx ** 2
        a = (slny * sx2 - sx * sxlny) / c
        b = ( n * sxlny - sx * slny ) / c
      
        return ::Math.exp(a), b, fit_error(xys) { |x| ::Math.exp(a + b * x) }
      end
      
      ##
      # Fits the functional form: a + bx.
      #
      # Takes x and y values and returns [a, b, r^2].
      #
      # See: http://mathworld.wolfram.com/LeastSquaresFitting.html
      
      def fit_linear xs, ys
        n   = xs.size
        xys = xs.zip(ys)
        sx  = sigma xs
        sy  = sigma ys
        sx2 = sigma(xs)  { |x|   x ** 2 }
        sxy = sigma(xys) { |x,y| x * y  }
      
        c = n * sx2 - sx**2
        a = (sy * sx2 - sx * sxy) / c
        b = ( n * sxy - sx * sy ) / c
      
        return a, b, fit_error(xys) { |x| a + b * x }
      end
      
      ##
      # To fit a functional form: y = ax^b.
      #
      # Takes x and y values and returns [a, b, r^2].
      #
      # See: http://mathworld.wolfram.com/LeastSquaresFittingPowerLaw.html
      
      def fit_power xs, ys
        n       = xs.size
        xys     = xs.zip(ys)
        slnxlny = sigma(xys) { |x, y| ::Math.log(x) * ::Math.log(y) }
        slnx    = sigma(xs)  { |x   | ::Math.log(x)               }
        slny    = sigma(ys)  { |   y| ::Math.log(y)               }
        slnx2   = sigma(xs)  { |x   | ::Math.log(x) ** 2          }
      
        b = (n * slnxlny - slnx * slny) / (n * slnx2 - slnx ** 2);
        a = (slny - b * slnx) / n
      
        return ::Math.exp(a), b, fit_error(xys) { |x| (::Math.exp(a) * (x ** b)) }
      end
      
      ##
      # Enumerates over +enum+ mapping +block+ if given, returning the
      # sum of the result. Eg:
      #
      #   sigma([1, 2, 3])                # => 1 + 2 + 3 => 7
      #   sigma([1, 2, 3]) { |n| n ** 2 } # => 1 + 4 + 9 => 14
      
      def sigma enum, &block
        enum = enum.map(&block) if block
        enum.inject { |sum, n| sum + n }
      end
    end
  end
end