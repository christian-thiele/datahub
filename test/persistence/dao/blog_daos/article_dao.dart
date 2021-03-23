@DaoType(name: 'article')
class ArticleDao {
  int x;
  final String y;

  @PrimaryKeyDaoField()
  final String z;

  @ForeignKeyDaoField(OtherTestClass)
  final String foreign;

  ArticleDao(this.x, this.y, this.z, this.foreign);
}