module JMACode
  module Blank
    refine Object do
      def blank?
        respond_to?(:empty?) ? !!empty? : !self
      end

      def present?
        !blank?
      end

      def presence
        self if present?
      end
    end

    refine NilClass do
      def blank?
        true
      end
    end

    refine FalseClass do
      def blank?
        true
      end
    end

    refine TrueClass do
      def blank?
        false
      end
    end

    refine Array do
      alias_method :blank?, :empty?
    end

    refine Hash do
      alias_method :blank?, :empty?
    end

    refine String do
      def blank?
        empty? || /\A[[:space:]]*\z/.match?(self)
      end
    end

    refine Numeric do
      def blank?
        false
      end
    end

    refine Time do
      def blank?
        false
      end
    end
  end
end
