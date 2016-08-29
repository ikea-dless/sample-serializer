# 複雑なJSONをレンダリングするところ選手権

## 候補者
- ActiveModelSerializer

### 特徴をざっくり

#### ActiveModelSerializer
- [v0.10.xのドキュメント](https://github.com/rails-api/active_model_serializers/tree/master/docs)
- json:apiの使用にしたがってparse, validateするjsonapi gemに依存している

  ###### [json:api](http://jsonapi.org/)
  - APIで返すjson形式の標準化をしようとしている
  - v1.0 stable
  - アンチ自転車小屋の議論(CoC)

##### いったん[getting start](https://github.com/rails-api/active_model_serializers/blob/master/docs/general/getting_started.md)する
- 基本はモデルと1:1
  - モデルがネームスペース切ってたら、serializerもネームスペースをあわせる
  - Api::Userモデルに対するSerializerはApi::UserSerializer
- 直感的
  - クラス作って、attribute定義する
- ApplicationSerializerも定義できる
- Adapterでjsonのフォーマットを定義する
  - https://github.com/rails-api/active_model_serializers/blob/master/docs/general/adapters.md
  - デフォルトではattributesアダプター
    - ルートキーなしで、そのままattributeを吐き出す
    ```json
    {
      "title": "Title 1",
      "body": "Body 1",
      "publish_at": "2020-03-16T03:55:25.291Z",
      "author": {
        "first_name": "Bob",
        "last_name": "Jones"
      },
      "comments": [
        {
          "body": "cool"
        },
        {
          "body": "awesome"
        }
      ]
    }
    ```
    - ルートキーありの :json アダプターとjson_apiに則った:json_apiアダプターもある
    ```json
    {
      "post": {
        "title": "Title 1",
        "body": "Body 1",
        "publish_at": "2020-03-16T03:55:25.291Z",
        "author": {
          "first_name": "Bob",
          "last_name": "Jones"
        },
        "comments": [{
          "body": "cool"
        }, {
          "body": "awesome"
        }]
      }
    }
    ```
    ↓ json:api仕様
    ```json
    {
      "data": {
        "id": "1337",
        "type": "posts",
        "attributes": {
          "title": "Title 1",
          "body": "Body 1",
          "publish-at": "2020-03-16T03:55:25.291Z"
        },
        "relationships": {
          "author": {
            "data": {
              "id": "1",
              "type": "authors"
            }
          },
          "comments": {
            "data": [{
              "id": "7",
              "type": "comments"
            }, {
              "id": "12",
              "type": "comments"
            }]
          }
        },
        "links": {
          "post-authors": "https://example.com/post_authors"
        },
        "meta": {
          "rating": 5,
          "favorite-count": 10
        }
      }
    }
    ```
    - けっこう簡単に自分でも書けそう
    - https://github.com/rails-api/active_model_serializers/blob/master/docs/general/adapters.md#advanced-adapter-configuration
    - jsonアダプターでも21行程度
      - https://github.com/rails-api/active_model_serializers/blob/master/lib/active_model_serializers/adapter/json.rb
- ルートキーをcamelとかback camelとかunder scoreとか変更できる
  - https://github.com/rails-api/active_model_serializers/blob/master/docs/general/key_transforms.md

| Option | Result |
|----|----|
| `:camel` | ExampleKey |
| `:camel_lower` | exampleKey |
| `:dash` | example-key |
| `:unaltered` | the original, unaltered key |
| `:underscore` | example_key |
| `nil` | use the adapter default |

- serializer上でmethodを定義
  - attributeをoverrideできる
  - defで定義する方法とattributeで定義する方法がある
    - 個人的にはdefにはロジックを記述したいから、基本はattribute使いたい

  ```ruby
  class SampleSerializer < ActiveModel::Serializer
    # attributes :id, :name
    attribute id do
      object.id.to_s
    end

    def name do
      object.name << "!!"
    end
  end
  ```

- アソシエーションタイプ
  - has_one, has_many, belongs_to
  - serializerからserializerへのリレーション
- いくつかオプションを渡せる
  - jsonのkey
  ```ruby
  has_one :user, key: :owner
  ```
  - serializer: モデルに紐付いていないserializerを指定できる
  ```ruby
  has_many :users, serializer: OwnersSerializer
  ```
  - if, unless

    ```ruby
    belongs_to :user, if: :visible?

    def visible?
      record.visible?
    end
    ```
    - serializerに定義するメソッドは、本当にserializerに定義すべきか考えないと、イカンコードになりそう

  - virtual_value: ダミーデータ使える
    - アソシエーション先をダミーデータにできる

    ```ruby
    has_many :posts, virtual_value: [{ id: 1 }, { id: 2 }]
    ```

  - polymorphic関連もよしなにやってくれる
  - blockも渡せる
    - いつ使うか不明

    ```ruby
    has_many :posts do
      Post.new(title: "hoge")
    end
    ```

- caching
  - railsのfragment_cacheっぽい
  - jsonのkeyごととかで設定できる
  - https://github.com/rails-api/active_model_serializers/issues/1586
    - バグ健在
    - キャッシュ使うときはちゃんとベンチ取る必要ありそう

- scope
  - action_controllerのインスタンス変数はviewテンプレートじゃないので受け取れない
  - current_user的なscopeを取得したいときはcontroller側にメソッドを生やす

```ruby
helper_method :current_member
serialization_scope :current_member # デフォルトはcurrent_user

private

def current_member
  @authenticated_member
end
```

- def name; endみたいにattribute nameでmethod定義するより、attributeにブロック渡すほうが、良さそう
  - def hogeはあくまでメソッドとして、とどめて、attributeに変更加えたいときはblock渡すべき

```ruby
def name
object.name << "!!!"
end

attribute name do # ActiveModel::Serializer::Attributes::ClassMethods#attribute
object.name << "!!!"
end
```

- render json したときにrailsはまずserializerを読みにいく
- serializerをrender jsonオプションに渡して指定できる
  - each_serializerとserializerオプションがある

- Non ActiveRecordオブジェクトはどうやってシリアライズする？
  - いわゆるvalue object的なやつ
  - https://github.com/rails-api/active_model_serializers/blob/master/docs/howto/serialize_poro.md
  - ActiveModelSerializers::Modelを継承させると楽に実装できそう
    - ただ、includeではなく継承なので、使いづらい部分はある
    - issueあった(修正されそう)
      - https://github.com/rails-api/active_model_serializers/issues/1877
- renderのオプションで特定のフィールドを指定できる
  - fields: { users: [:name] }
- jsonのkeyはなんだかんだいい感じに指定できる
- instrumentationも提供されている
- 独自Adapterを書くのはそんなに難しくなさそう
  - meta入れたいだけだったら jsonアダプター使うのが良さそう
    - metaの中身はハッシュで指定できそう
  - いろいろひっくるめてASM Wayに乗りたいんであればjsonapiアダプターが良さそう
  - metaを許容する設計にすれば良さそう

#### 総括
- json:apiに合わせた設計はされていくだろう
- json:apiに準拠するのであれば、だいぶ幸せな世界が待っているはず
- serializerをバンバン切っていけば結構柔軟にできそう
  - serializerの切り方は少し考えないといけなさそう
- 総じてActiveModelライクな感じだった
- メジャーバージョンを切っていないので不安要素は残るが、実戦投入するには問題なさそう
  - issue見て、クリティカルなバグがないことを確認すべき
