using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ComikSanBackend.Migrations
{
    /// <inheritdoc />
    public partial class FixChaptersRelation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ChapterId",
                table: "Chapters",
                type: "TEXT",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "ChapterNumber",
                table: "Chapters",
                type: "TEXT",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "Pages",
                table: "Chapters",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "PublishedAt",
                table: "Chapters",
                type: "TEXT",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Volume",
                table: "Chapters",
                type: "TEXT",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ChapterId",
                table: "Chapters");

            migrationBuilder.DropColumn(
                name: "ChapterNumber",
                table: "Chapters");

            migrationBuilder.DropColumn(
                name: "Pages",
                table: "Chapters");

            migrationBuilder.DropColumn(
                name: "PublishedAt",
                table: "Chapters");

            migrationBuilder.DropColumn(
                name: "Volume",
                table: "Chapters");
        }
    }
}
