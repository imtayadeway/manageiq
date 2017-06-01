RSpec.describe ShareSweeper do
  before { allow(User).to receive(:server_timezone).and_return("UTC") }

  it "is invalidated when the sharee is no longer has the features that were shared" do
    EvmSpecHelper.seed_specific_product_features(%w(host service))
    user = FactoryGirl.create(:user, :role => "user", :features => "service")
    resource_to_be_shared = FactoryGirl.create(:miq_template)
    features = [MiqProductFeature.find_by(:identifier => "service")]
    share = create_share(user, resource_to_be_shared, features)

    replace_user_features(user, "host")

    expect { share.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  specify "the share is destroyed if the entitlement filters to not cover the tags on the resource" do
    EvmSpecHelper.seed_specific_product_features(%w(host))
    group = FactoryGirl.create(:miq_group, :role => "user", :features => "host")
    group.entitlement.set_managed_filters([["/managed/environment/prod"]])
    group.save
    user = FactoryGirl.create(:user, :miq_groups => [group])
    resource_to_be_shared = FactoryGirl.create(:miq_template)
    resource_to_be_shared.tag_with("/managed/environment/prod", :ns => "*")
    features = [MiqProductFeature.find_by(:identifier => "host")]
    share = create_share(user, resource_to_be_shared, features)

    group.entitlement.set_managed_filters([["/managed/environment/dev"]])
    group.save

    expect { share.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  def create_share(user, resource, features)
    tenant = FactoryGirl.create(:tenant)
    ResourceSharer.new(
      :user     => user,
      :resource => resource,
      :tenants  => [tenant],
      :features => features
    ).share
    tenant.shares.first
  end

  def replace_user_features(user, *identifiers)
    user.miq_user_role.miq_product_features = []
    identifiers.each do |identifier|
      user.miq_user_role.miq_product_features << MiqProductFeature.find_by(:identifier => identifier)
    end
  end
end
