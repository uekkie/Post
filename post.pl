use strict;
use warnings;

#===========================================
# 必要なデータに整形する
#	01101,"060  ","0600000","ﾎｯｶｲﾄﾞｳ","ｻｯﾎﾟﾛｼﾁｭｳｵｳｸ","ｲｶﾆｹｲｻｲｶﾞﾅｲﾊﾞｱｲ","北海道","札幌市中央区","以下に掲載がない場合",0,0,0,0,0,0
#			↓↓↓
#	"0600000","ﾎｯｶｲﾄﾞｳ","ｻｯﾎﾟﾛｼﾁｭｳｵｳｸ","ｲｶﾆｹｲｻｲｶﾞﾅｲﾊﾞｱｲ","北海道","札幌市中央区","以下に掲載がない場合",
#
sub trimData {
	# コンマ区切りで配列に格納
	my @datas = split(/\,/ , shift);
	my $result = "";

	for (@datas) {
		# ダブルコーテーションで囲まれたデータのみ残す
		# 旧郵便番号データは要らない(数字:3<=X<=5、半角SP:0<=X<=2 のデータ)
		$result .= "$_," if (/^\".+\"$/ && ! /\"[0-9]{3,5} {0,2}\"/);
	}
	$result;
}


sub main {
	my $fin = shift;
	# ファイル拡張子チェック
	if ($fin !~ /\.csv$/) {
		print "please select CSV file.\n";
		return;
	}
	my $fout = $fin;
	$fout =~ s/\./\.out\./g;
	
	open(my $in, "<", $fin) or die("could not open file.");
	open(my $out, ">", $fout) or die("could not open file.");

	while (<$in>) {
		print $out trimData($_)."\n";
	}

	close($in);
	close($out);
}

# 処理するファイルをコマンド引数で受け取る
main($ARGV[0]);