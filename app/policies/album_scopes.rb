# frozen_string_literal: true

module DFans
  # Policy to determine if account can view a album
  class AlbumPolicy
    # Scope of album policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_albums(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |alb|
            includes_participator?(alb, @current_account)
          end
        end
      end

      private

      def all_albums(account)
        account.owned_albums + account.participations
      end

      def includes_participator?(album, account)
        album.participators.include? account
      end
    end
  end
end
