# RSpec テストパターン集

このプロジェクトのRSpecテストで使用するカテゴリ別テンプレート。生成するspecはこれらのパターンに準拠すること。

## モデルスペック

```ruby
require "rails_helper"

RSpec.describe ModelName, type: :model do
  describe "バリデーション" do
    context "field_nameが未入力の場合" do
      let(:record) { build(:model_name, field_name: nil) }

      it "バリデーションエラーになる" do
        expect(record).not_to be_valid
        expect(record.errors[:field_name]).to include("を入力してください")
      end
    end

    context "field_nameが正しい場合" do
      let(:record) { build(:model_name, field_name: "valid_value") }

      it "バリデーションが通る" do
        expect(record).to be_valid
      end
    end
  end

  describe "アソシエーション" do
    let_it_be(:record) { create(:model_name) }

    it "belongs_to :parent" do
      expect(record).to respond_to(:parent)
    end

    it "has_many :children" do
      expect(record).to respond_to(:children)
    end
  end

  describe "スコープ" do
    describe ".scope_name" do
      let!(:matching) { create(:model_name, :matching_trait) }
      let!(:non_matching) { create(:model_name) }

      it "条件に一致するレコードを返す" do
        expect(described_class.scope_name).to include(matching)
        expect(described_class.scope_name).not_to include(non_matching)
      end
    end
  end

  describe "#instance_method" do
    subject(:result) { record.instance_method }

    let(:record) { create(:model_name) }

    context "正常系" do
      it "期待される結果を返す" do
        expect(result).to eq(expected_value)
      end
    end
  end

  describe ".class_method" do
    subject(:result) { described_class.class_method(args) }

    context "正常系" do
      it "期待される結果を返す" do
        expect(result).to eq(expected_value)
      end
    end
  end
end
```

## サービススペック

```ruby
require "rails_helper"

RSpec.describe ServiceName do
  describe "#method_name" do
    subject(:service) { described_class.new(dependency1:, dependency2:) }

    let(:dependency1) { create(:factory_name) }
    let(:dependency2) { create(:factory_name) }

    context "正常系" do
      it "期待される結果を返す" do
        expect(service.method_name).to be true
      end
    end

    context "異常系: 条件の説明" do
      let(:dependency1) { create(:factory_name, :invalid_trait) }

      it "falseを返す" do
        expect(service.method_name).to be false
      end
    end
  end

  describe ".class_method" do
    subject(:result) { described_class.class_method(args) }

    context "正常系" do
      it "期待される結果を返す" do
        expect(result).to eq(expected_value)
      end
    end

    context "異常系" do
      it "エラーを発生させる" do
        expect { result }.to raise_error(StandardError, "エラーメッセージ")
      end
    end
  end
end
```

## インタラクションスペック

ActiveInteractionを使用するクラスのテストパターン。`outcome.valid?`と`outcome.result`で結果を検証する。

```ruby
require "rails_helper"

RSpec.describe Interactions::InteractionName do
  describe ".run" do
    let(:user) { create(:user) }
    let(:valid_params) do
      {
        user:,
        param1: "value1",
        param2: "value2",
      }
    end

    context "正常系" do
      it "成功する" do
        outcome = described_class.run(valid_params)
        expect(outcome).to be_valid
        expect(outcome.result).to be_a(ExpectedClass)
      end

      it "副作用が正しく実行される" do
        expect {
          described_class.run(valid_params)
        }.to change(Model, :count).by(1)
      end
    end

    context "バリデーションエラー" do
      it "必須パラメータが不足している場合" do
        outcome = described_class.run(valid_params.except(:param1))
        expect(outcome).not_to be_valid
        expect(outcome.errors[:param1]).to be_present
      end
    end

    context "異常系" do
      let(:invalid_params) { valid_params.merge(param1: "invalid") }

      it "エラーを返す" do
        outcome = described_class.run(invalid_params)
        expect(outcome).not_to be_valid
        expect(outcome.errors[:base]).to include("エラーメッセージ")
      end
    end
  end
end
```

## GraphQL ミューテーションスペック

`gql_context` ヘルパーを使用してGraphQLコンテキストを構築する。

```ruby
require "rails_helper"

RSpec.describe Mutations::MutationName do
  describe "#resolve" do
    subject(:resolve_mutation) do
      described_class.new(
        object: nil,
        context: gql_context({ current_user: user }),
        field: nil,
      ).resolve(**input)
    end

    let(:user) { create(:user) }
    let(:input) do
      {
        param1: "value1",
        param2: "value2",
      }
    end

    context "正常系" do
      it "期待される変更が行われる" do
        expect { resolve_mutation }.to change(Model, :count).by(1)
      end

      it "正しい結果を返す" do
        result = resolve_mutation
        expect(result[:field_name]).to eq(expected_value)
      end
    end

    context "未認証の場合" do
      let(:user) { nil }

      it "エラーを返す" do
        expect { resolve_mutation }.to raise_error(GraphQL::ExecutionError)
      end
    end

    context "バリデーションエラーの場合" do
      let(:input) { { param1: "" } }

      it "エラーを返す" do
        expect { resolve_mutation }.to raise_error(GraphQL::ExecutionError)
      end
    end
  end
end
```

## GraphQL リゾルバスペック

```ruby
require "rails_helper"

RSpec.describe Resolvers::ResolverName do
  describe "#resolve" do
    subject(:resolved) do
      described_class.new(
        object: nil,
        context: gql_context({ current_user: user }),
        field: nil,
      ).resolve(**args)
    end

    let(:user) { create(:user) }
    let(:args) { {} }

    context "正常系" do
      it "期待されるデータを返す" do
        expect(resolved).to include(expected_data)
      end
    end

    context "未認証の場合" do
      let(:user) { nil }

      it "エラーを返す" do
        expect { resolved }.to raise_error(GraphQL::ExecutionError)
      end
    end
  end
end
```

## GraphQL タイプスペック

```ruby
require "rails_helper"

RSpec.describe Types::TypeName do
  describe "フィールド定義" do
    it "期待されるフィールドを持つ" do
      fields = described_class.fields
      expect(fields).to have_key("fieldName")
    end

    describe "fieldName" do
      let(:field) { described_class.fields["fieldName"] }

      it "正しい型を持つ" do
        expect(field.type.to_type_signature).to eq("String!")
      end
    end
  end
end
```

## ジョブスペック

```ruby
require "rails_helper"

RSpec.describe JobName do
  describe "#perform" do
    let(:user) { create(:user) }

    context "正常系" do
      it "期待される処理が実行される" do
        expect {
          described_class.perform_now(user.id)
        }.to change(Model, :count).by(1)
      end
    end

    context "対象が存在しない場合" do
      it "エラーをハンドリングする" do
        expect {
          described_class.perform_now(0)
        }.not_to raise_error
      end
    end
  end
end
```

## ワーカースペック

Sidekiq::Workerを使用するクラスのテストパターン。

```ruby
require "rails_helper"

RSpec.describe WorkerName do
  describe "#perform" do
    let(:user) { create(:user) }

    context "正常系" do
      it "期待される処理が実行される" do
        expect {
          described_class.new.perform(user.id)
        }.to change(Model, :count).by(1)
      end
    end

    context "対象が存在しない場合" do
      it "エラーをハンドリングする" do
        expect {
          described_class.new.perform(0)
        }.not_to raise_error
      end
    end
  end
end
```

## コントローラスペック

プロジェクト固有のカスタムマッチャ（`be_api_success`, `be_operational_error`等）を使用する。

```ruby
require "rails_helper"

RSpec.describe Api::V3::ControllerName, type: :controller do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe "GET #index" do
    subject { get :index, params: params }

    let(:params) { {} }

    context "正常系" do
      it "成功レスポンスを返す" do
        subject
        expect(response).to be_api_success
      end
    end

    context "未認証の場合" do
      before { sign_out }

      it "エラーレスポンスを返す" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST #create" do
    subject { post :create, params: params }

    let(:params) { { model_name: attributes } }
    let(:attributes) { { field: "value" } }

    context "正常系" do
      it "レコードが作成される" do
        expect { subject }.to change(Model, :count).by(1)
        expect(response).to be_api_success
      end
    end

    context "バリデーションエラーの場合" do
      let(:attributes) { { field: "" } }

      it "エラーレスポンスを返す" do
        subject
        expect(response).to be_operational_error("エラーメッセージ")
      end
    end
  end
end
```

## ポリシースペック

action_policy/rspecのDSLを使用する。

```ruby
require "rails_helper"

RSpec.describe PolicyName do
  let(:user) { create(:user) }
  let(:record) { create(:model_name) }

  describe "#action_name?" do
    subject { described_class.new(record, user:) }

    context "権限がある場合" do
      it "許可される" do
        expect(subject.action_name?).to be true
      end
    end

    context "権限がない場合" do
      let(:user) { create(:user, :without_permission) }

      it "拒否される" do
        expect(subject.action_name?).to be false
      end
    end
  end
end
```

## バリデータスペック

```ruby
require "rails_helper"

RSpec.describe ValidatorName do
  let(:model_class) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :field_name
      validates :field_name, validator_name: true
    end
  end

  let(:record) { model_class.new }

  describe "#validate_each" do
    context "有効な値の場合" do
      before { record.field_name = "valid_value" }

      it "バリデーションが通る" do
        expect(record).to be_valid
      end
    end

    context "無効な値の場合" do
      before { record.field_name = "invalid" }

      it "エラーが追加される" do
        expect(record).not_to be_valid
        expect(record.errors[:field_name]).to be_present
      end
    end
  end
end
```

## デコレータスペック

```ruby
require "rails_helper"

RSpec.describe DecoratorName do
  let(:record) { create(:model_name) }
  let(:decorator) { described_class.new(record) }

  describe "#decorated_method" do
    it "整形された値を返す" do
      expect(decorator.decorated_method).to eq("expected_formatted_value")
    end
  end
end
```

## サービスラッパースペック

外部APIを呼び出すクラスは必ずWebMockでスタブ化する。

```ruby
require "rails_helper"

RSpec.describe ServiceWrapperName do
  describe "#method_name" do
    subject(:result) { described_class.new.method_name(args) }

    context "正常系" do
      before do
        stub_request(:get, "https://api.example.com/endpoint")
          .to_return(status: 200, body: { data: "value" }.to_json)
      end

      it "APIレスポンスを正しく処理する" do
        expect(result).to eq(expected_value)
      end
    end

    context "APIエラーの場合" do
      before do
        stub_request(:get, "https://api.example.com/endpoint")
          .to_return(status: 500, body: "Internal Server Error")
      end

      it "エラーをハンドリングする" do
        expect { result }.to raise_error(ServiceWrapperName::ApiError)
      end
    end
  end
end
```

## メーラースペック

```ruby
require "rails_helper"

RSpec.describe MailerName, type: :mailer do
  describe "#action_name" do
    subject(:mail) { described_class.action_name(user) }

    let(:user) { create(:user) }

    it "正しい宛先に送信される" do
      expect(mail.to).to eq([user.email])
    end

    it "正しい件名を持つ" do
      expect(mail.subject).to eq("期待される件名")
    end

    it "本文に必要な情報が含まれる" do
      expect(mail.body.encoded).to include(user.name)
    end
  end
end
```

## 共通パターン

### 時刻依存のテスト

```ruby
context "期限切れの場合" do
  it "falseを返す" do
    travel_to Time.zone.local(2025, 1, 1) do
      expect(result).to be false
    end
  end
end
```

### データベース変更の検証

```ruby
it "レコードが作成される" do
  expect { subject }.to change(Model, :count).by(1)
end

it "属性が更新される" do
  expect { subject }.to change { record.reload.field_name }.from("old").to("new")
end
```

### ジョブのエンキュー検証

```ruby
it "ジョブがエンキューされる" do
  expect { subject }.to have_enqueued_job(JobName).with(expected_args)
end
```

### shared_examples

```ruby
shared_examples "認証が必要なアクション" do
  context "未認証の場合" do
    it "401を返す" do
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

# 使用
it_behaves_like "認証が必要なアクション"
```
