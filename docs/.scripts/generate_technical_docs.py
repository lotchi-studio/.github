"""Generate the code reference pages automatically."""

# Built-in
import ast
from pathlib import Path

# Third-party
import mkdocs_gen_files

# Directories to skip (checked against path parts for efficiency)
SKIP_DIRS = frozenset({"__pycache__", ".deprecated", "_dev"})
SKIP_FILES = frozenset({"__main__"})


def get_module_docstring(file_path: Path) -> str | None:
    """Extract the module-level docstring from a Python file."""
    try:
        source = file_path.read_bytes()
        tree = ast.parse(source, filename=str(file_path))
        docstring = ast.get_docstring(tree)
        if docstring:
            return docstring.split("\n", 1)[0].strip()
        return None
    except (SyntaxError, UnicodeDecodeError, OSError):
        return None


def should_skip(path: Path) -> bool:
    """Check if path should be skipped based on directory or file name."""
    parts = path.parts
    return any(part in SKIP_DIRS for part in parts) or path.stem in SKIP_FILES


nav = mkdocs_gen_files.Nav()

root = Path(__file__).parent.parent.parent
src = root / "python"

# Filter paths once, then process
paths = [p for p in src.rglob("*.py") if not should_skip(p)]

for path in sorted(paths):
    module_path = path.relative_to(src).with_suffix("")
    doc_path = path.relative_to(src).with_suffix(".md")
    full_doc_path = Path("technical", doc_path)

    parts = tuple(module_path.parts)

    # For __init__ files, use index.md and trim the part from nav
    if parts[-1] == "__init__":
        parts = parts[:-1]
        if not parts:
            continue
        doc_path = doc_path.with_name("index.md")
        full_doc_path = full_doc_path.with_name("index.md")

    # Nav paths should be relative to the technical/ folder
    nav[parts] = doc_path.as_posix()

    with mkdocs_gen_files.open(full_doc_path, "w") as fd:
        ident = ".".join(parts)

        # # Add module docstring as description if available
        # docstring = get_module_docstring(path)
        # if docstring:
        #     # Use only the first line/sentence of the docstring
        #     first_line = docstring.split("\n")[0].strip()
        #     fd.write(f"# {parts[-1]}\n\n")
        #     fd.write(f"_{first_line}_\n\n")
        #     fd.write("---\n\n")

        fd.write(f"::: {ident}")

    mkdocs_gen_files.set_edit_path(full_doc_path, path.relative_to(root))

with mkdocs_gen_files.open("technical/SUMMARY.md", "w") as nav_file:
    nav_file.writelines(nav.build_literate_nav())
