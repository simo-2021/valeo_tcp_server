cd buildroot/
echo "--- Starting Clean ---"
make aesd-assignments-dirclean
echo "--- Clean Done. Waiting 3 seconds... ---"
sleep 3
echo "--- Starting Build with $(nproc) cores ---"
make -j$(nproc)
echo "--- Build Finished ---"

cd ..
