# frozen_string_literal: true

require 'minitest/autorun'

# リポジトリに public/ が含まれる場合、配信用 index がルートと一致していること
# （手で public だけ編集した・prepare 忘れを検知）
class PublicDeployParityTest < Minitest::Test
  ROOT = File.expand_path('../..', __dir__)

  def test_public_index_matches_root_when_present
    root_p = File.join(ROOT, 'index.html')
    pub_p = File.join(ROOT, 'public', 'index.html')
    skip 'public/index.html なし（hosting:prepare 未実行のクローン等）' unless File.file?(pub_p)

    assert_equal File.binread(root_p), File.binread(pub_p),
                 'public/index.html がルート index.html と不一致です。bundle exec rake hosting:prepare を実行してください。'
  end
end
