use lib './t';
use Test::More;
use Test::Exception;
use Mock::Basic;

my $skinny = Mock::Basic->new;
$skinny->setup_test_db;

ok($skinny->can('proxy_table'), 'proxy_table can call');
isa_ok($skinny->proxy_table, 'DBIx::Skinny::ProxyTable');

my $table = "access_log_200901";
$skinny->proxy_table->copy_table('access_log' => $table);

dies_ok {
    $skinny->search($table, {});
};

ok(!$skinny->attribute->{row_class_map}->{$table}, 'row class map should not be exist yet');
$skinny->proxy_table->set('access_log', $table);
ok($skinny->schema->schema_info->{$table}, 'schema_info should be exist ');
is($skinny->attribute->{row_class_map}->{$table}, $skinny->attribute->{row_class_map}->{'access_log'}, 'row class map should be exist');

lives_ok {
    $skinny->search($table, {});
};

my $iter = $skinny->search($table);
isa_ok($iter, "DBIx::Skinny::Iterator");

dies_ok {
    $skinny->proxy_table->set('access_log', 'access_log.fuga');
};

dies_ok {
    $skinny->proxy_table->set('access_log', 'access_log; fuga');
};

done_testing();
