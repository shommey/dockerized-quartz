const express = require("express");
const { exec } = require("child_process");

const app = express();
const PORT = 3000;
const SECRET = process.env.REBUILD_WEBHOOK_SECRET;

app.use(express.json());

app.post("/rebuild/:secret", (req, res) => {
    if (req.params.secret !== SECRET) {
        return res.status(403).json({ error: "Forbidden" });
    }

    exec("/usr/src/app/scripts/build-quartz.sh", (error, stdout, stderr) => {
        if (error) {
            console.error(`Webhook failed with error: ${stderr}`);
            return res.status(500).json({ error: "Script execution failed" });
        }
        console.log(`Webhook trigger: ${stdout}`);
        res.json({ success: true, message: "Rebuild triggered" });
    });
});

app.listen(PORT, "127.0.0.1", () => {
    console.log(`Webhook server running on http://127.0.0.1:${PORT}`);
});
