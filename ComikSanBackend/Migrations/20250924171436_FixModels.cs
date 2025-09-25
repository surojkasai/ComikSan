using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ComikSanBackend.Migrations
{
    /// <inheritdoc />
    public partial class FixModels : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CoverImageUrl",
                table: "Comics",
                type: "TEXT",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "Comics",
                type: "TEXT",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "LastSynced",
                table: "Comics",
                type: "TEXT",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MangaDexId",
                table: "Comics",
                type: "TEXT",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CoverImageUrl",
                table: "Comics");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "Comics");

            migrationBuilder.DropColumn(
                name: "LastSynced",
                table: "Comics");

            migrationBuilder.DropColumn(
                name: "MangaDexId",
                table: "Comics");
        }
    }
}
