import { exec } from "child_process";
import { promisify } from "util";
import * as fs from "fs";
import * as path from "path";

const execAsync = promisify(exec);

const vulnerablePackages = readVulnerablePackagesFile();

async function run() {
  console.log("Checking for potentially vulnerable packages...");
  console.log("------------------------------------------------");

  const packagesBatched = vulnerablePackages.reduce((acc, pkg, index) => {
    const batchIndex = Math.floor(index / 20);
    acc[batchIndex] ||= [];
    acc[batchIndex].push(pkg);
    return acc;
  }, []);

  for (const batch of packagesBatched) {
    await Promise.all(batch.map(checkPackage));
  }
}

async function checkPackage({ name, version }) {
  console.log(`${name} <-> ${version}`);
  // Execute npm ls command to find installed versions
  const command = `npm ls ${name} --all --depth=Infinity`;
  const { stdout } = await execAsync(command).catch((e) => e);

  const installedVersions = extractVersions(stdout, name);
  installedVersions.forEach((installedVersion) => {
    console.log(`Package ${name} installed version ${installedVersion}`);
    if (installedVersion.includes(version)) {
      throw Error(`Vulnerable package detected: ${name}@${version}`);
    }
  });
}

function extractVersions(output, packageName) {
  const regex = new RegExp(`${packageName}@([^ ]+)`, "g");
  const versions = new Set();
  let match;

  while ((match = regex.exec(output)) !== null) {
    versions.add(match[1]);
  }

  return Array.from(versions).sort();
}

function readVulnerablePackagesFile() {
  const filePath = path.resolve("./packages.txt");
  if (!fs.existsSync(filePath)) {
    throw new Error(`Packages.txt file not found: ${filePath}`);
  }
  const data = fs.readFileSync(filePath, "utf-8");
  return data.split("\n").map((line) => {
    const [firstPositon, secondPosition, thirdPosition] = line.split("@");
    if (thirdPosition === undefined) {
      return {
        name: firstPositon,
        version: secondPosition
      }
    }

    return {
      name : firstPositon + secondPosition, 
      version: thirdPosition,
    };
  });
}

// Run the package checker
run()
  .then((res) => {
    console.log("Package check completed successfully with no vulnerabilities found.");
  })
  .catch((error) => {
    console.error("Error running package checker:", error);
    process.exit(1);
  });
