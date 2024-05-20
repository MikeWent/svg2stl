import os
import shutil
import subprocess
import tempfile
import uuid
from random import randbytes

from flask import Flask, flash, render_template, request, send_file
from werkzeug.utils import secure_filename

app = Flask(__name__)


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/upload", methods=["POST"])
def upload():
    if "file" not in request.files:
        flash("No file part")
        return render_template("index.html")

    file = request.files["file"]
    if file.filename == "":
        flash("No selected file")
        return render_template("index.html")

    filename = secure_filename(file.filename)
    original_name, ext = os.path.splitext(filename)
    temp_dir = tempfile.mkdtemp()
    input_path = os.path.join(temp_dir, str(uuid.uuid4()) + ext)

    try:
        file.save(input_path)

        options = []
        options_str = ""
        if request.form.get("negative") == "true":
            options.append("-1")
            options_str += "_negative"

        output_filename = f"{uuid.uuid4()}.stl"
        output_path = os.path.join(temp_dir, output_filename)
        command = ["/app/svg2stl.sh", input_path, output_path] + options

        result = subprocess.run(
            command, timeout=30, capture_output=True, text=True, cwd=temp_dir
        )
        stdout = result.stdout
        stderr = result.stderr
        if result.returncode != 0:
            raise subprocess.CalledProcessError(
                result.returncode, command, output=stdout, stderr=stderr
            )
        return send_file(
            output_path,
            as_attachment=True,
            download_name=f"{original_name}{options_str}.stl",
        )
    except subprocess.CalledProcessError as e:
        flash(f"error: {e} -- stdout: {e.output} -- stderr: {e.stderr}")
    except subprocess.TimeoutExpired:
        flash("timeout expired")
    except Exception as e:
        flash(f"exception: {e}")
    finally:
        shutil.rmtree(temp_dir)
    return render_template("index.html")


if __name__ == "__main__":
    app.secret_key = randbytes(128)
    app.config["MAX_CONTENT_LENGTH"] = 16 * 1024 * 1024  # 16 MB
    app.config["TEMPLATES_AUTO_RELOAD"] = True
    app.run(threaded=True, host="0.0.0.0", port=8044)
