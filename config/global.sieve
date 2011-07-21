require "fileinto";

if header :contains ["X-Spam-Flag"] ["yes"] {
  fileinto "Spam.Detected";
}

# // End of file //
