using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ComikSanBackend.Migrations
{
    /// <inheritdoc />
    public partial class UpdateModels : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Pages",
                table: "Chapters");

            migrationBuilder.AddColumn<int>(
                name: "Height",
                table: "Pages",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "PageNumber",
                table: "Pages",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Width",
                table: "Pages",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "GroupName",
                table: "Chapters",
                type: "TEXT",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Height",
                table: "Pages");

            migrationBuilder.DropColumn(
                name: "PageNumber",
                table: "Pages");

            migrationBuilder.DropColumn(
                name: "Width",
                table: "Pages");

            migrationBuilder.DropColumn(
                name: "GroupName",
                table: "Chapters");

            migrationBuilder.AddColumn<int>(
                name: "Pages",
                table: "Chapters",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);
        }
    }
}
